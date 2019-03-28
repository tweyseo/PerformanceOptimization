-- function reference
local setmetatable = setmetatable
local ipairs = ipairs
local lower = string.lower
local insert = table.insert
local xpcall = xpcall
local traceback = debug.traceback
-- include
local routerConf = require("app.conf").router
local Matcher = require("app.route.matcher.index")
local utils = require("app.utils")

local Router = {}

function Router:new(routeMode)
    local instance = {}
    instance.matcher = Matcher.new(routeMode)
    setmetatable(instance, { __index = self })

    return instance
end

function Router:addMiddlewares(path, func)
    self.matcher:addMiddlewares(path, func)
end

function Router:addErrHandler(path, func)
    self.matcher:addErrHandler(path, func)
end

local function mergeHandlers(node)
    local handlers
    if node.middlewares == nil then
        handlers = { node.handler }
    else
        handlers = utils.newTab(#node.middlewares, 0)
        -- deep copy
        for i, v in ipairs(node.middlewares) do
            handlers[i] = v
        end

        insert(handlers, node.handler)
    end

    return handlers
end

function Router.errProcess(srcErr, req, resp, errHandlers, finalHandler)
    if errHandlers == nil or #errHandlers == 0 then
        return finalHandler(srcErr)
    end
    -- use onion model to invoke error handlers
    local idx = #errHandlers + 1
    local function next(err)
        if idx <= 1 then
            return finalHandler(nil)
        end

        idx = idx - 1
        local errHandler = errHandlers[idx]
        errHandler(err, req, resp, next)
    end

    next(srcErr)
end

function Router:process(req, resp, finalHandler)
    local node
    local pOk, pErr = xpcall(function()
        local path, method, Err404 = req.path, lower(req.method), routerConf.Err404
        if path == nil or method == nil then
            resp:setStatus(Err404.ec)
            -- use root error handler of the matcher to process 404 error
            return self.errProcess(Err404.em, req, resp, self.matcher:rootErrHandlers()
                , finalHandler)
        end

        -- node { middlewares, errHandlers, handler }
        node = self.matcher:capture(path, method)
        if node == nil then
            resp:setStatus(Err404.ec)
            -- use root error handler of the matcher to process 404 error
            return self.errProcess(Err404.em, req, resp, self.matcher:rootErrHandlers()
                , finalHandler)
        end

        req:setFound(true)

        -- merge middlewares and handler
        local handlers = mergeHandlers(node)

        -- use onion model to invoke handlers (middlewares and handler)
        local idx, len = 0, #handlers
        local function next(err)
            if err ~= nil then
                return self.errProcess(err, req, resp, node.errHandlers, finalHandler)
            end

            if idx >= len then
                return finalHandler(nil)
            end

            idx = idx + 1
            local handler = handlers[idx]
            handler(req, resp, next)
        end

        next()
    end, traceback)

    if pOk ~= true then
        pOk, pErr = xpcall(self.errProcess, traceback, pErr, req, resp
            , node and node.errHandlers or self.matcher:rootErrHandlers(), finalHandler)
    end

    if pOk ~= true then
        finalHandler(pErr)
    end
end

-- auto generate forward function and cache them
setmetatable(Router, { __index = function(_, method)
        local f = function(self, ...)
            -- router equal to self
            local matcher = self.matcher
            return matcher[method](matcher, ...)
        end

        Router[method] = f

        return f
    end})

return Router