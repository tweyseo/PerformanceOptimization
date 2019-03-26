local v = require("jit.v")
v.on("appTrace.log")

local max = 10
local function trace(op, app)
    for _ = 1, max do
        op(app)
    end
end

local main = require("main")

local app1 = main.init()
trace(main.addMiddleware, app1)
--[[trace(main.addErrHandler, app1)
trace(main.addHandler, app1)]]

--[[local app2 = main.init()
main.addMiddleware(app2)
main.addErrHandler(app2)
main.addHandler(app2)
trace(main.run, app2)]]

