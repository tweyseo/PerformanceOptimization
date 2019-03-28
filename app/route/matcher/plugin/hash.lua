-- function reference
local setmetatable = setmetatable
local type = type
local pairs = pairs
local ipairs = ipairs
local find = ngx.re.find -- todo: add resty.core
local insert = table.insert
local error = error
-- include
local conf = require("app.route.matcher.conf")
local utils = require("app.utils")
local split = require("ngx.re").split
-- const
local mwIdx, ehIdx, hdIdx = 1, 2, 3 -- for instance.nodes.path
local pathIdx, methodIdx, nodeIdx, countIdx = 1, 2, 3, 4  --for instance.cache
local rootGroupId = 1
local defaultGroupLength = 64
local additionalLength = #conf.caret + #conf.slash

-- static route for exact match (URI without colon and regex)
-- note that addMiddlewares and addErrHandlers must be invoked before calling addHandler
local Hash = {}

function Hash:new()
    local instance = {}
    --[[
        to implement the idea of the onion model and more easier generation of static routes, the
        middlewares and the errHandlers was grouped by path length, like onions. the middlewares
        was grouped in order from short to long, and which was inverse in the errHandlers.
    ]]
    --[[
        { { path1 = { function1, function2, ... } , path2 = { function1, function2, ... }, ... }
        , { path1 = { function1, function2, ... } , path2 = { function1, function2, ... }, ... }
        , ... }
    ]]
    instance.middlewares = utils.newTab(defaultGroupLength, 0)
    -- similar with middlewares
    instance.errHandlers = utils.newTab(defaultGroupLength, 0)
    --[[
        nodes = {
            path = {
            { function1, function2, ... }   -- middlewares under this path
            , { function1, function2, ... } -- errHandlers under this path
            , { method1 = function1, method2 = function2, ... } -- method handler under this path
            } }
    ]]
    instance.nodes = {}
    -- only cacahe one path with hot counter
    instance.cache = {}
    setmetatable(instance, { __index = self })

    instance:init()

    return instance
end

function Hash:init()
    for i = 1, defaultGroupLength do
        self.middlewares[i] = {}
        self.errHandlers[i] = {}
    end
end

-- return groupId and more regular path for easier generation of static routes
local function groupPath(path)
    -- root path
    if path == conf.rootPath then
        return rootGroupId, path
    end

    local m, err = split(path, conf.slash, "jo")
    if err then
        error(err)
    end
    --[[
        the length of the split result (#m) decided the group id.
        caret and slash add in path was for exact matching (e.g. /test or /test2 do not match
        /test1/test2, but /test1 do).
    ]]
    return #m, conf.caret..path..conf.slash
end

-- nil path means root "/"
function Hash:addMiddlewares(path, func)
    if type(path) == "function" then
        func = path
        path = conf.rootPath
    end

    local groupId, newPath = groupPath(path)
    local group = self.middlewares[groupId]

    local funcList = group[newPath]
    if funcList == nil then
        group[newPath] = { func }
        return
    end

    insert(funcList, func)
end

-- nil path means root "/"
function Hash:addErrHandlers(path, func)
    if type(path) == "function" then
        func = path
        path = conf.rootPath
    end

    local groupId, newPath = groupPath(path)
    local group = self.errHandlers[groupId]

    local funcList = group[newPath]
    if funcList == nil then
        group[newPath] = { func }
        return
    end

    insert(funcList, func)
end

-- collect handlers from middlewares or errHandlers for generation of static routes
local function collectHandlers(groups, srcPath)
    local handlerList = {}
    for groupId, group in ipairs(groups) do
        -- root path
        if groupId == rootGroupId then
            for _, func in ipairs(group[conf.rootPath]) do
                insert(handlerList, func)
            end
        else
            for path, funcList in pairs(group) do
                -- filter with length first, and additionalLength is length of caret and slash
                if #srcPath >= #path - additionalLength
                    and find(srcPath..conf.slash, path, "jo") ~= nil then
                    for _, func in ipairs(funcList) do
                        insert(handlerList, func)
                    end
                end
            end
        end
    end

    return handlerList
end

-- note that, different path with different method only map one handler.
function Hash:addHandler(method, path, func)
    local node = self.nodes[path]
    if node == nil then
        self.nodes[path] = { collectHandlers(self.middlewares, path)
            , collectHandlers(self.errHandlers, path)
            , { [method] = func } }

        return
    end
    -- override the old method handler function (if already exists)
    node[hdIdx][method] = func
end

--[[
    root error handler process:
    1. an error occurred before the node was found
    2. the found node has no error handler
]]
function Hash:rootErrHandlers()
    local rootGroup = self.errHandlers[rootGroupId]
    return rootGroup and rootGroup[conf.rootPath]
end

local function searchCache(self, path, method)
    local cache = self.cache
    if cache[pathIdx] == path and cache[methodIdx] == method then
        cache[countIdx] = cache[countIdx] + 1
        return cache[nodeIdx]
    end
end

local function missCache(self, path, method, node)
    if self.cache[countIdx] == nil or self.cache[countIdx] == 1 then
        self.cache = { path, method, node, 1 }
        return
    end

    self.cache[countIdx] = self.cache[countIdx] - 1
end

function Hash:dumpCache()
    local cache = self.cache
    return { path = cache[pathIdx], method = cache[methodIdx], count = cache[countIdx] }
end

function Hash:capture(path, method)
    local node = searchCache(self, path, method)
    if node ~= nil then
        return { middlewares = node[mwIdx], errHandlers = node[ehIdx]
            , handler = node[hdIdx][method] }
    end

    local miss = true
    node = self.nodes[path]
    if node == nil then
        return
    end

    local pathHandlers = node[hdIdx]
    if pathHandlers == nil then
        return
    end

    local methodHandler = pathHandlers[method]
    if methodHandler == nil then
        return
    end

    if miss == true then
        missCache(self, path, method, node)
    end

    return { middlewares = node[mwIdx], errHandlers = node[ehIdx], handler = methodHandler }
end

return Hash