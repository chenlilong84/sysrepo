%module libsysrepoLua51

%include <stdint.i>

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
#include <signal.h>

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


volatile int exit_application = 0;

static void
sigint_handler(int signum)
{
    exit_application = 1;
}


static void global_loop() {
    /* loop until ctrl-c is pressed / SIGINT is received */
    signal(SIGINT, sigint_handler);
    while (!exit_application) {
        sleep(1000);  /* or do some more useful work... */
    }
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

%ignore Value::Value(double decimal64_val, sr_type_t type = SR_DECIMAL64_T);
%ignore Value::Value(int8_t int8_val, sr_type_t type = SR_INT16_T);
%ignore Value::Value(int16_t int16_val, sr_type_t type = SR_INT16_T);
%ignore Value::Value(int32_t int32_val, sr_type_t type = SR_INT32_T);
%ignore Value::Value(uint8_t uint8_val, sr_type_t type = SR_UINT8_T);
%ignore Value::Value(uint16_t uint16_val, sr_type_t type = SR_UINT16_T);
%ignore Value::Value(uint32_t uint32_val, sr_type_t type = SR_UINT32_T);
%ignore Value::Value(uint64_t uint64_val, sr_type_t type = SR_UINT64_T);

%include "../swig_base/base.i"
