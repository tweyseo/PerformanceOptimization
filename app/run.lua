local now = ngx.now
local update = ngx.update_time
local max = 10 * 1e5
local function elapsedTime(op, app, name)
    local beginTime = now()
    for _ = 1, max do
        op(app)
    end
    update()
    print(name, " run [", max, "] times, elapsed time: ", now() - beginTime)
end

local main = require("main")

local app = main.init()
main.addMiddleware(app)
main.addErrHandler(app)
main.addHandler(app)
elapsedTime(main.run, app, "'run'")