require("jit.v").on("vlog")
local main = require("main")

local max = 1e3
local function trace(op, app)
    for _ = 1, max do
        op(app)
    end
end

local app = main.init()
main.addMiddleware(app)
main.addErrHandler(app)
main.addHandler(app)
trace(main.run, app)