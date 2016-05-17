#ifndef Sysrepo_H
#define Sysrepo_H

#include <iostream>

extern "C" {
#include "sysrepo.h"
}

class Throw_Exception
{

protected:
    void throw_exception(int error);
};

class Logs
{
public:
    Logs();
    void set_stderr(sr_log_level_t log_level);
    void set_syslog(sr_log_level_t log_level);
};

class Errors
{
public:
    Errors();
    size_t cnt;
    const sr_error_info_t *info;
};

class Schema
{

public:
    size_t cnt;
    sr_schema_t *sch;
    char *content;
};

#endif /* defined(Sysrepo_H) */
