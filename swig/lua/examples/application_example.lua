sys = require("libsysrepoLua51")

function print_value(value)

   if (value:get_type() == sys.SR_CONTAINER_T) then
      print(value:get_xpath(), "(container)")
   elseif (value:get_type() == sys.SR_CONTAINER_PRESENCE_T) then
      print(value:get_xpath(), "(container)")
   elseif (value:get_type() == sys.SR_LIST_T) then
      print(value:get_xpath(), "(list instance)")
   elseif (value:get_type() == sys.SR_STRING_T) then
      print(value:get_xpath(), "= ", value:get_string())
   elseif (value:get_type() == sys.SR_BOOL_T) then
      if (value:get_bool()) then
         print(value:get_xpath(), "= true")
      else
         print(value:get_xpath(), "= false")
      end
   elseif (value:get_type() == sys.SR_UINT8_T) then
      print(value:get_xpath(), "= ", value:get_uint8())
   elseif (value:get_type() == sys.SR_UINT16_T) then
      print(value:get_xpath(), "= ", value:get_uint16())
   elseif (value:get_type() == sys.SR_UINT32_T) then
      print(value:get_xpath(), "= ", value:get_uint32())
   end
end

function print_current_config(sess)

    function run()
        xpath = "/ietf-interfaces:*//*";
        values = sys.Values()

        sess:get_items(xpath, values)

        repeat
            print_value(values)
        until (not values:Next())
    end

    ok,res=pcall(run)
    if not ok then
        print("\nerror: ",res, "\n")
    end

end

function module_change_cb(session, module_name, event, private_ctx)
    print("\n\n ========== CONFIG HAS CHANGED, CURRENT RUNNING CONFIG: ==========\n");

    sess = sys.Session(session)
    print_current_config(sess)
end

function run()
    conn = sys.Connection("application")
    sess = sys.Session(conn)

    print("\n\n ========== READING STARTUP CONFIG: ==========\n");
    print_current_config(sess);

    subscribe = sys.Subscribe(sess)

    fn = sys.Wrap_cb(module_change_cb)

    subscribe:module_change_subscribe_lua("ietf-interfaces", fn);

    print("\n\n ========== STARTUP CONFIG APPLIED AS RUNNING ==========\n");

    while true do
        sys.lua_sleep(1000)
    end

    print("Application exit requested, exiting.\n");
end

ok,res=pcall(run)
if not ok then
    print("\nerror: ",res, "\n")
end
