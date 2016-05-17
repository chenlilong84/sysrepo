sys = require("libsysrepoLua51")

function a()
   conn = sys.Connection("app2")
   sess = sys.Session(conn)
   values = sys.Values()

   xpath = "/ietf-interfaces:interfaces/interface"

   sess:get_items(xpath, values)

   repeat
       print(values:get_xpath())
   until (not values:Next())
end

ok,res=pcall(a)
if not ok then
    print("\nerror:",res, "\n")
end
