-- function reference
local pcall = pcall
local type = type
-- include
local json = require("cjson")

local utils = {}

local ok
ok, utils.newTab = pcall(require, "table.new")
if not ok or type(utils.newTab) ~= "function" then
    utils.newTab = function() return {} end
end

function utils.jsonEncode(luaValue, asArray)
    local jsonValue
    if json.encode_empty_table_as_object then
        -- empty table encoded as array default
        json.encode_empty_table_as_object(asArray or true)
    end
    -- prevent from excessively sparse array
    json.encode_sparse_array(true)
    pcall(function(v) jsonValue = json.encode(v) end, luaValue)
    return jsonValue
end

function utils.jsonDecode(jsonValue)
    local luaValue
    pcall(function(v) luaValue = json.decode(v) end, jsonValue)
    return luaValue
end

return utils