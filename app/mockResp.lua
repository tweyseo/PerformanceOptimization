-- function reference
-- include

local Response = {}

function Response:new()
    local instance = {
        status = 200
    }
    setmetatable(instance, { __index = self })

    return instance
end

function Response:setStatus(status)
    self.status = status
    return self
end

function Response:send(msg)
    --print("resp client: "..(msg or self.status))
end

return Response
