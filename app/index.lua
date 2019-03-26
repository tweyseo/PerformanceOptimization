-- function reference
local setmetatable = setmetatable
local error = error
local rawget = rawget
-- include
local appConf = require("app.conf").app
local Router = require("app.route.router")
local Request = require("app.mockReq")--require("app.request")
local Response = require("app.mockResp")--require("app.response")

local App = {}

-- default route mode is hash (static)
function App:new(routeMode)
    local instance = {}
    instance.router = Router:new(routeMode)
    setmetatable(instance, { __index = self })

    return instance
end

function App:use(path, func)
    self.router:addMiddlewares(path, func)
end

function App:errUse(path, func)
    self.router:addErrHandlers(path, func)
end

function App:dumpCache()
    return self.router:dumpCache()
end

function App:run(finalHandler)
    self.router:process(Request:new(), Response:new(), finalHandler or function(err)
        if err ~= nil then
            error(err)
        end
    end)
end

-- auto generate http method function and cache them
setmetatable(App, { __index = function(self, method)
        if appConf.httpMethods[method] == true then
            local f = function(this, path, func)
                return this.router:addHandler(method, path, func)
            end

            App[method] = f

            return f
        else
            -- trigger lua error
            return rawget(self, method)
        end
    end})

return App