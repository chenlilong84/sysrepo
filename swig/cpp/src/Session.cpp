#include <stdexcept>
#include <iostream>

#include "Sysrepo.h"
#include "Value.h"
#include "Connection.h"
#include "Session.h"

extern "C" {
#include "sysrepo.h"
}

using namespace std;

Session::Session(Connection& conn, sr_datastore_t datastore, const sr_conn_options_t opts, \
		 const char *user_name)
{
    int ret;
    _opts = opts;
    _datastore = datastore;

    if (user_name == NULL) {
        /* start session */
        ret = sr_session_start(conn.get_conn(), _datastore, _opts, &_sess);
        if (SR_ERR_OK != ret) {
            goto cleanup;
        }
    } else {
        /* start session */
        ret = sr_session_start_user(conn.get_conn(), user_name, _datastore, _opts, &_sess);
        if (SR_ERR_OK != ret) {
            goto cleanup;
        }
    }

    return;

cleanup:
    throw_exception(ret);
    return;
}

Session::Session(sr_session_ctx_t *sess)
{
    _sess = sess;
}

void Session::session_stop()
{
    int ret = sr_session_stop(_sess);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::get_last_error(Errors& err)
{
    int ret = sr_get_last_error(_sess, &err.info);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::get_last_errors(Errors& err)
{
    int ret = sr_get_last_errors(_sess, &err.info, &err.cnt);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::list_schemas(Schema& schema)
{
    int ret = sr_list_schemas(_sess, &schema.sch, &schema.cnt);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::get_schema(Schema& schema, const char *module_name, const char *revision,
	       	const char *submodule_name,  sr_schema_format_t format)
{
    int ret = sr_get_schema(_sess, module_name, revision, submodule_name, format, &schema.content);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::get_item(const char *xpath, Value *value)
{

    sr_val_t *tmp_val = NULL;

    int ret = sr_get_item(_sess, xpath, &tmp_val);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }

    value->Set(&tmp_val[0]);

    return;
}

void Session::get_items_iter(const char *xpath, Iter *iter)
{
    sr_val_iter_t *tmp_iter = NULL;

    int ret = sr_get_items_iter(_sess, xpath, &tmp_iter);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }

    iter->Set(tmp_iter);

    return;
}

void Session::get_items(const char *xpath, Values *values)
{
    sr_val_t *tmp_val = NULL;
    size_t tmp_cnt = 0;

    int ret = sr_get_items(_sess, xpath, &tmp_val, &tmp_cnt);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }

    values->Set(tmp_val, tmp_cnt);

    return;
}

bool Session::get_item_next(Iter *iter, Value *value)
{
    sr_val_t *tmp_val = NULL;

    if (SR_ERR_OK == sr_get_item_next(_sess, iter->Get(), &tmp_val)){
        value->Set(tmp_val);
        return true;
    }

    return false;
}

void Session::set_item(const char *xpath, Value& value, const sr_edit_options_t opts)
{
    int ret = sr_set_item(_sess, xpath, *value.Get(), opts);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::delete_item(const char *xpath, const sr_edit_options_t opts)
{
    int ret = sr_delete_item(_sess, xpath, opts);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::move_item(const char *xpath, const sr_move_position_t position, const char *relative_item)
{
    int ret = sr_move_item(_sess, xpath, position, relative_item);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::refresh()
{
    int ret = sr_session_refresh(_sess);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::validate()
{
    int ret = sr_validate(_sess);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::commit()
{
    int ret = sr_commit(_sess);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::lock_datastore()
{
    int ret = sr_lock_datastore(_sess);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::unlock_datastore()
{
    int ret = sr_unlock_datastore(_sess);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::lock_module(const char *module_name)
{
    int ret = sr_lock_module(_sess, module_name);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::unlock_module(const char *module_name)
{
    int ret = sr_unlock_module(_sess, module_name);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

void Session::discard_changes()
{
    int ret = sr_discard_changes(_sess);
    if (ret != SR_ERR_OK) {
        throw_exception(ret);
    }
    return;
}

Session::~Session()
{
    if (_sess) {
        int ret = sr_session_stop(_sess);
        if (ret != SR_ERR_OK) {
            throw_exception(ret);
        }
	_sess = NULL;
    }
}

Subscribe::Subscribe(Session *sess)
{
    _sub = NULL;
    _sess = sess;
    #ifndef SWIG
    swig_sub = _sub;
    swig_sess = _sess;
    #endif
}

Subscribe::~Subscribe()
{
    if (_sub) {
        int ret = sr_unsubscribe(_sess->Get(), _sub);
        if (ret != SR_ERR_OK) {
            throw_exception(ret);
        }
	_sub = NULL;
    }
}

sr_session_ctx_t *Session::Get()
{
    return _sess;
}

void Subscribe::module_change_subscribe(const char *module_name, sr_module_change_cb callback, \
                                        void *private_ctx, uint32_t priority, sr_subscr_options_t opts)
{
    int ret = 0;

    ret = sr_module_change_subscribe(_sess->Get(), module_name, callback, private_ctx, priority, opts, &_sub);
    if (SR_ERR_OK != ret) {
        throw_exception(ret);
    }
}
