#include <iostream>
#include <stdexcept>

#include "Sysrepo.h"

extern "C" {
#include "sysrepo.h"
#include <stdlib.h>
}

using namespace std;

void Throw_Exception::throw_exception(int error)
{
    switch(error) {
    case(SR_ERR_INVAL_ARG):
        throw runtime_error(sr_strerror(SR_ERR_INVAL_ARG));
    case(SR_ERR_NOMEM):
        throw runtime_error(sr_strerror(SR_ERR_NOMEM));
    case(SR_ERR_NOT_FOUND):
        throw runtime_error(sr_strerror(SR_ERR_NOT_FOUND));
    case(SR_ERR_INTERNAL):
        throw runtime_error(sr_strerror(SR_ERR_INTERNAL));
    case(SR_ERR_INIT_FAILED):
        throw runtime_error(sr_strerror(SR_ERR_INIT_FAILED));
    case(SR_ERR_IO):
        throw runtime_error(sr_strerror(SR_ERR_IO));
    case(SR_ERR_DISCONNECT):
        throw runtime_error(sr_strerror(SR_ERR_DISCONNECT));
    case(SR_ERR_MALFORMED_MSG):
        throw runtime_error(sr_strerror(SR_ERR_MALFORMED_MSG));
    case(SR_ERR_UNSUPPORTED):
        throw runtime_error(sr_strerror(SR_ERR_UNSUPPORTED));
    case(SR_ERR_UNKNOWN_MODEL):
        throw runtime_error(sr_strerror(SR_ERR_UNKNOWN_MODEL));
    case(SR_ERR_BAD_ELEMENT):
        throw runtime_error(sr_strerror(SR_ERR_BAD_ELEMENT));
    case(SR_ERR_VALIDATION_FAILED):
        throw runtime_error(sr_strerror(SR_ERR_VALIDATION_FAILED));
    case(SR_ERR_DATA_EXISTS):
        throw runtime_error(sr_strerror(SR_ERR_DATA_EXISTS));
    case(SR_ERR_DATA_MISSING):
        throw runtime_error(sr_strerror(SR_ERR_DATA_MISSING));
    case(SR_ERR_UNAUTHORIZED):
        throw runtime_error(sr_strerror(SR_ERR_UNAUTHORIZED));
    case(SR_ERR_LOCKED):
        throw runtime_error(sr_strerror(SR_ERR_LOCKED));
    case(SR_ERR_TIME_OUT):
        throw runtime_error(sr_strerror(SR_ERR_TIME_OUT));
    }
}

Errors::Errors()
{
    // for consistent swig integration
    return;
}

Logs::Logs()
{
    // for consistent swig integration
    return;
}

void Logs::set_stderr(sr_log_level_t log_level)
{
    sr_log_stderr(log_level);
}

void Logs::set_syslog(sr_log_level_t log_level)
{
    sr_log_stderr(log_level);
}
