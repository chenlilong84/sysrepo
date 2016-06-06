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

    void send_to_lua(sr_session_ctx_t *session, const char *module_name, sr_notif_event_t event, \
                     void *private_ctx) {
        swiglua_ref_get(&fn);
        SWIG_NewPointerObj(fn.L, session, SWIGTYPE_p_sr_session_ctx_s, 0);
        lua_pushstring(fn.L, module_name);
        lua_pushnumber(fn.L, (lua_Number)(int)(event));
        SWIG_NewPointerObj(fn.L, private_ctx, SWIGTYPE_p_void, 0);
        lua_call(fn.L, 4, 0);
    }

    void *private_ctx;

private:
    SWIGLUA_REF fn;
};

static int global_cb(sr_session_ctx_t *session, const char *module_name, sr_notif_event_t event, \
                     void *private_ctx)
{
    Wrap_cb *ctx = (Wrap_cb *) private_ctx;
    ctx->send_to_lua(session, module_name, event, ctx->private_ctx);

    return SR_ERR_OK;
}

static void lua_sleep(int m)
{
    usleep(m * 1000);
}

%}

%extend Subscribe {

void module_change_subscribe_lua(const char *module_name, Wrap_cb *class_ctx, void *private_ctx = NULL, \
                                 uint32_t priority = 0, sr_subscr_options_t opts = SR_SUBSCR_DEFAULT) {
        int ret = 0;
        class_ctx->private_ctx = private_ctx;
        ret = sr_module_change_subscribe(self->swig_sess->Get(), module_name, global_cb, class_ctx,
                                         0, 0, &self->swig_sub);
        if (SR_ERR_OK != ret) {
            throw std::runtime_error(sr_strerror(ret));
        }
    };
};

%include "../swig_base/base.i"
