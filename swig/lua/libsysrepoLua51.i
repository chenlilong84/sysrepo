%module libsysrepoLua51

%{
    extern "C" {
        #include "../inc/sysrepo.h"
    }
%}

%include <std_except.i>
%catches(std::runtime_error, std::exception, std::string);

%include "lua_fnptr.i"

%inline %{
#include <unistd.h>
#include "../inc/sysrepo.h"

class Wrap_cb {
public:
    Wrap_cb(SWIGLUA_REF fn) : fn(fn) {};

    void send_to_lua(sr_session_ctx_t *session, const char *module_name, void *private_ctx) {
        swiglua_ref_get(&fn);
        SWIG_NewPointerObj(fn.L, session, SWIGTYPE_p_sr_session_ctx_s, 0);
        lua_pushstring(fn.L, module_name);
        SWIG_NewPointerObj(fn.L, private_ctx, SWIGTYPE_p_void, 0);
        lua_call(fn.L, 3, 0);
    }

    void *private_ctx;

private:
    SWIGLUA_REF fn;
};

static void global_cb(sr_session_ctx_t *session, const char *module_name, void *private_ctx)
{
    Wrap_cb *ctx = (Wrap_cb *) private_ctx;
    ctx->send_to_lua(session, module_name, ctx->private_ctx);
}

static void lua_sleep(int m)
{
    usleep(m * 1000);
}

%}

%extend Subscribe {
    void module_change_subscribe_lua(const char *module_name, bool enable_running, \
                                 Wrap_cb *class_ctx, void *private_ctx) {
        int ret = 0;
        class_ctx->private_ctx = private_ctx;
        ret = sr_module_change_subscribe(self->swig_sess->Get(), module_name, enable_running, \
                                         global_cb, class_ctx, &self->swig_sub);
        if (SR_ERR_OK != ret) {
            throw std::runtime_error(sr_strerror(ret));
        }
    };
};

%include "../swig_base/base.i"
