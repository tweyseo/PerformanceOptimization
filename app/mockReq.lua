local random = math.random
-- comment this function to log result
local function print() end

local Request = {}

local pm = {
    "/test1/test2/test3",
    "/test1/test2",
    "/test1",
}

math.randomseed(ngx.now())

function Request:new()
    local instance = {
        path = pm[random(1, 3)],
        method = "GET",

        found = false
    }
    setmetatable(instance, { __index = self })

    print("client req: ", instance.path, ", method: ", instance.method)
    return instance
end

function Request:isFound()
    return self.found
end

function Request:setFound(found)
    self.found = found
end

return Request