require("resty.core") -- should be add at stage of init_worker_by_lua
-- comment this function to log result
local function print() end

local App = require("app.index")

local main = {}

function main.init()
    return App:new()
end

function main.addMiddleware(app)
    app:use(function(_, _, next) print("use-mw-root1") next(nil) end)
    app:use(function(_, _, next) print("use-mw-root2") next(nil) end)
    app:use("/test1/test2/test3", function(_, _, next) print("use-mw-test1-test2-test3-1") next(nil)
        end)
    app:use("/test1/test2/test3", function(_, _, next) print("use-mw-test1-test2-test3-2") next(nil)
        end)
    app:use("/test1/test2", function(_, _, next) print("use-mw-test1-test2-1") next(nil) end)
    app:use("/test1/test2", function(_, _, next) print("use-mw-test1-test2-2") next(nil) end)
    app:use("/test1", function(_, _, next) print("use-mw-test1-1") next(nil) end)
    app:use("/test1", function(_, _, next) print("use-mw-test1-2") next(nil) end)
end

function main.addErrHandler(app)
    app:errUse(function(err, _, _, next) print("use-eh-root1: ", err) next(err)end)
    app:errUse(function(err, _, _, next) print("use-eh-root2: ", err) next(err)end)
    app:errUse("/test1/test2/test3", function(err, _, _, next)
            print("use-eh-test3-test2-test1-1: ", err) next(err)
        end)
    app:errUse("/test1/test2/test3", function(err, _, _, next)
            print("use-eh-test3-test2-test1-2: ", err) next(err)
        end)
    app:errUse("/test1/test2", function(err, _, _, next) print("use-eh-test2-test1-1: ", err)
            next(err)
        end)
    app:errUse("/test1/test2", function(err, _, _, next) print("use-eh-test2-test1-2: ", err)
            next(err)
        end)
    app:errUse("/test1", function(err, _, _, next)  print("use-eh-test1-1: ", err) next(err) end)
    app:errUse("/test1", function(err, _, _, next)  print("use-eh-test1-2: ", err) next(err) end)
end

function main.addHandler(app)
    app:get("/test1", function(_, resp, next) print("handle-test1") resp:send() next(nil) end)
    app:get("/test1/test2", function(_, resp, next) print("handle-test2") resp:send() next(nil) end)
    app:get("/test1/test2/test3", function(_, resp, next) print("handle-test3") resp:send()
            next(nil)
        end)
end

function main.run(app)
    app:run(function(err)
        if err ~= nil then
            print("final error handler: "..err)
        end
    end)
end

return main