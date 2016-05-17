sys = require("libsysrepoLua51")

function a()
    log = sys.Logs()
    log:set_stderr(sys.SR_LL_DBG)

    conn = sys.Connection("app3")
    sess = sys.Session(conn)

    xpath = "/ietf-interfaces:interfaces/interface[name='gigaeth0']/ietf-ip:ipv6/address[ip='fe80::ab8']/prefix-length"

    num = 64;
    value = sys.Value(num, sys.SR_INT64_T)
    sess:set_item(xpath, value)
    sess:commit()
end

ok,res=pcall(a)
if not ok then
    print("\nerror:",res, "\n")
end
