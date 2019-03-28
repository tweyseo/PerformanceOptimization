local random = math.random
local split = require("ngx.re").split
local v = require("jit.dump")
v.on("is", "testTrace.dlog")

local function f(path)
    local m, err = split(path, "/", "jo")
    if err then
        error(err)
    end

    return #m
end

local pathList = {
    "/test1/test2/test3/test4/test5",
    "/test1/test2/test3/test4",
    "/test1/test2/test3",
    "/test1/test2",
    "/test1"
}

local max, len = 10e1, #pathList
for _ = 1, max do
    f(pathList[random(1, len)])
end

local newTab = require("table.new")
local t = newTab(64, 0)
t[1] = 13
print(t[1])