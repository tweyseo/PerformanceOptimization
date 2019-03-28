require("resty.core") -- should be add at stage of init_worker_by_lua
-- comment this function to log result
local function print() end

local App = require("app.index")

local main = {}

function main.init()
    return App:new()
end

local function f1(_, _, next)
    print("use-mw-root1")
    next(nil)
end

local function f2(_, _, next)
    print("use-mw-root2")
    next(nil)
end

local function f3(_, _, next)
    print("use-mw-test1-test2-test3-1")
    next(nil)
end

local function f4(_, _, next)
    print("use-mw-test1-test2-test3-2")
    next(nil)
end

local function f5(_, _, next)
    print("use-mw-test1-test2-1")
    next(nil)
end

local function f6(_, _, next)
    print("use-mw-test1-test2-2")
    next(nil)
end

local function f7(_, _, next)
    print("use-mw-test1-1")
    next(nil)
end

local function f8(_, _, next)
    print("use-mw-test1-2")
    next(nil)
end

function main.addMiddleware(app)
    app:use(f1)
    app:use(f2)
    app:use("/test1/test2/test3", f3)
    app:use("/test1/test2/test3", f4)
    app:use("/test1/test2", f5)
    app:use("/test1/test2", f6)
    app:use("/test1", f7)
    app:use("/test1", f8)
end

local function g1(err, _, _, next)
    print("use-eh-root1: ", err)
    next(err)
end

local function g2(err, _, _, next)
    print("use-eh-root2: ", err)
    next(err)
end

local function g3(err, _, _, next)
    print("use-eh-test3-test2-test1-1: ", err)
    next(err)
end

local function g4(err, _, _, next)
    print("use-eh-test3-test2-test1-2: ", err)
    next(err)
end

local function g5(err, _, _, next)
    print("use-eh-test2-test1-1: ", err)
    next(err)
end

local function g6(err, _, _, next)
    print("use-eh-test2-test1-2: ", err)
    next(err)
end

local function g7(err, _, _, next)
    print("use-eh-test1-1: ", err)
    next(err)
end

local function g8(err, _, _, next)
    print("use-eh-test1-2: ", err)
    next(err)
end

function main.addErrHandler(app)
    app:errUse(g1)
    app:errUse(g2)
    app:errUse("/test1/test2/test3", g3)
    app:errUse("/test1/test2/test3", g4)
    app:errUse("/test1/test2", g5)
    app:errUse("/test1/test2", g6)
    app:errUse("/test1", g7)
    app:errUse("/test1", g8)
end

local function h1(_, resp, next)
    print("handle-test1")
    resp:send()
    next(nil)
end

local function h2(_, resp, next)
    print("handle-test2")
    resp:send()
    next(nil)
end

local function h3(_, resp, next)
    print("handle-test3")
    resp:send()
    next(nil)
end

function main.addHandler(app)
    app:get("/test1", h1)
    app:get("/test1/test2", h2)
    app:get("/test1/test2/test3", h3)
end

local function feh(err)
    if err ~= nil then
        print("final error handler: "..err)
    end
end

function main.run(app)
    app:run(feh)
end

return main