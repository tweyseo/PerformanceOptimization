local now = ngx.now
local update = ngx.update_time
local max = 5 * 10e4
local function elapsedTime(op, app, name)
    local beginTime = now()
    for _ = 1, max do
        op(app)
    end
    update()
    print(name, " run [", max, "] times, elapsed time: ", now() - beginTime)
end

local main = require("main")

local app1 = main.init()
elapsedTime(main.addMiddleware, app1, "'addMiddleware'")
elapsedTime(main.addErrHandler, app1, "'addErrHandler'")
elapsedTime(main.addHandler, app1, "'addHandler'")

--[[local app2 = main.init()
main.addMiddleware(app2)
main.addErrHandler(app2)
main.addHandler(app2)
elapsedTime(main.run, app2, "'run'")]]