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

function a()
   conn = sys.Connection("app2")
   sess = sys.Session(conn)
   value = sys.Value()

   xpath = "/ietf-interfaces:interfaces/interface//*"

   iter = sys.Iter()
   sess:get_items_iter(xpath, iter)

   while (sess:get_item_next(iter,value))
   do
       print_value(value)
   end
end

ok,res=pcall(a)
if not ok then
    print("\nerror:",res, "\n")
end
