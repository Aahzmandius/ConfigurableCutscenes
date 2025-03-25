Helpers = Helpers or {}
Helpers.Net = Helpers.Net or {}

---@param v table|userdata
---@return boolean
local function isVector(v)
    if #v == 3 then
        return type(v[1]) == "number" and type(v[2]) == "number" and type(v[3]) == "number"
    elseif #v == 4 then
        return type(v[1]) == "number" and type(v[2]) == "number" and type(v[3]) == "number" and type(v[4]) == "number"
    else
        return false
    end
end

--- @param vt any # Ext.Types.GetValueType() result
local function isScalarType(vt)
    return vt == "nil" or vt == "string" or vt == "number" or vt == "boolean" or vt == "Enum" or vt == "Bitfield" or vt == "function"
end
--- @param ty TypeInformation
local function isTypeScalar(ty)
    return ty.Kind == "Boolean" or ty.Kind == "Enumeration" or ty.Kind == "Float" or ty.Kind == "Integer" or ty.Kind == "String"
end
-- Rare edge case of light userdata with possibly no SE-defined iterator, wrap with pcall
local function isUserdataEdgecase(v)
    return Ext.Types.GetValueType(v) == "userdata" and not pcall(function() for _,_ in pairs(v) do end end)
end
local function isEntity(v)
    return Ext.Types.GetValueType(v) == "Entity"
end
local function isPlausiblyScalar(v)
    local vt = Ext.Types.GetValueType(v)
    return isScalarType(vt) or (vt == "table" and isVector(v))
end
local function isArrayOfScalarTypes(val)
    local typeName = Ext.Types.GetObjectType(val)
    local typeInfo = Ext.Types.GetTypeInfo(typeName)
    return typeInfo and (typeInfo.Kind == "Array" or typeInfo.Kind == "Set") and isTypeScalar(typeInfo.ElementType)
end
local function isExpandableType(v)
    local ret = not isPlausiblyScalar(v) and not isEntity(v) and not isArrayOfScalarTypes(v) and not isUserdataEdgecase(v)
    SDebug("Expandable: %s? %s", tostring(v), ret)
    return ret
end

--- @param v EntityHandle
local function replaceEntity(v)
    local context = Ext.IsServer() and "Server" or "Client"
    local id = Ext.Entity.HandleToUuid(v --[[@as EntityHandle]])
    -- () for uuid'd entities, [] for non-uuid'd entities (integer handle)
    if not id then
        id = "["..tostring(Ext.Utils.HandleToInteger(v --[[@as EntityHandle]])).."]"
    else
        id = "("..id..")"
    end
    return ("%sEntity%s"):format(context, id)
end

local function processValue(v, seen, nestLevel)
    if type(v) == "userdata" and Ext.Types.GetValueType(v) == "Entity" then
        return replaceEntity(v)
    elseif isExpandableType(v) then
        return Helpers.Net.SanitizeForNet(v, seen, nestLevel + 1)
    elseif isUserdataEdgecase(v) then
        return "NetSanitize:OopsNoIterator"
    else
        return v
    end
end

--- Sanitized for safe stringify over netmessages, recursive
---[x] lua scalars (number, string, boolean, nil)
---[x] lua tables
---[x] Entities (formatted as "ContextEntity(uuid)" or "ContextEntity[intHandle]", eg- "ServerEntity(b6e858a8-8075-4929-8054-5c184c1395be)"
---[ ] Specially accessible userdata; Set, Array, Map
--- @param data table|userdata
--- @param seen table<any, boolean>? # Used to prevent infinite recursion
--- @param nestLevel number? # Used to track the current nesting level for debug output
--- @return any
function Helpers.Net.SanitizeForNet(data, seen, nestLevel)
    nestLevel = nestLevel or 1
    local indent = string.rep("\t", nestLevel)
    if not data then return nil end
    local sanitized = {}
    local seen = seen or {}
    -- Check if we've seen this table or userdata yet
    if type(data) == "table" or type(data) == "userdata" then
        if seen[data] then
            SPrint("%sAlready seen, skipping: %s", indent, tostring(data))
            return "*RECURSION*"
        end
        seen[data] = true
    end

    -- Go through fields
    for k,v in pairs(data) do
        SPrint("%s============ Sanitizing: %s ============ ", indent, k)
        -- Check seen data first
        if type(v) == "table" or type(v) == "userdata" then
            if seen[v] then
                SPrint("%sAlready seen, skipping: %s", indent, tostring(v))
                sanitized[k] = "*RECURSION*"
                goto continue
            end
            seen[v] = true
        end
        -- Skip functions and threads (who even)
        if type(v) == "function" or type(v) == "thread" then
            SPrint("%sFunction/Thread", indent)
        -- Simple tables, recurse
        elseif type(v) == "table" then
            SPrint("%sTable", indent)
            local tbl = {}
            for k2,v2 in pairs(v) do
                if type(v2) == "table" or type(v2) == "userdata" then
                    local seenKey = ("%s%s"):format(tostring(k2),tostring(v2))
                    if seen[seenKey] then
                        tbl[k2] = "*RECURSION*"
                    else
                        seen[seenKey] = true
                        tbl[k2] = processValue(v2, seen, nestLevel)
                    end
                else
                    tbl[k2] = processValue(v2, seen, nestLevel)
                end
            end
            sanitized[k] = tbl
        -- Userdata and simple types
        else
            local valueType = Ext.Types.GetValueType(v)
            local objectType = Ext.Types.GetObjectType(v)
            if type(v) == "userdata" then
                SPrint("%sUserdata", indent)
                local ti = Ext.Types.GetTypeInfo(objectType)
                if valueType == "Entity" then
                    -- Handle entity specially
                    sanitized[k] = replaceEntity(v)
                    SPrint("%s\tUserdata: Entity: %s", indent, sanitized[k])
                elseif ti and ti.Kind == "Set" then
                    local set = {}
                    for key = 1, #v do
                        local val = Ext.Types.GetHashSetValueAt(v, key)
                        if seen[val] then
                            set[key] = "*RECURSION*"
                        else
                            seen[val] = true
                            set[key] = processValue(val, seen, nestLevel)
                        end
                    end
                    sanitized[k] = set
                    SPrint("%s\tUserdata: Set: %s", indent, sanitized[k])
                elseif ti and ti.Kind == "Array" then
                    local array = {}
                    for i = 1, #v do
                        local val = v[i]
                        if val ~= nil then
                            if seen[val] then
                                array[i] = "*RECURSION*"
                            else
                                seen[val] = true
                                array[i] = processValue(val, seen, nestLevel)
                            end
                        else
                            array[i] = "nil"
                        end
                    end
                    sanitized[k] = array
                    SPrint("%s\tUserdata: Array: %s", indent, sanitized[k])
                elseif ti and ((ti.Kind == "Map") or valueType == "CppObject") then
                    local tbl = {}

                    local keys = {}
                    for key,_ in pairs(v --[[@as table]]) do
                        table.insert(keys, key)
                    end
                    table.sort(keys)
                    for _,key in ipairs(keys) do
                        local val = v[key]
                        if key and val then
                            if seen[val] then
                                tbl[key] = "*RECURSION*"
                            else
                                seen[val] = true
                                tbl[key] = processValue(val, seen, nestLevel)
                            end
                        end
                    end
                    sanitized[k] = tbl
                    SPrint("%s\tUserdata: Map: %s", indent, sanitized[k])
                else
                    SPrint("%s\tUserdata: Simple: %s", indent, valueType)
                    sanitized[k] = v
                end
            else
                SPrint("%s\tOther simple type: %s(%s)[%s]", indent, type(v), valueType, objectType)
                sanitized[k] = v
            end
        end
        ::continue::
    end
    return sanitized
end


--- Recursively search for unserializable types (Array, Set, Map) and print their paths
--- @param data table|userdata The data to search through
--- @param seen table<any, boolean>? Used to prevent infinite recursion
--- @param path string? Current path in the data structure
function Helpers.Net.CombForUnserializable(data, seen, path)
    seen = seen or {}
    path = path or "root"

    if seen[data] then return end
    if type(data) == "table" or type(data) == "userdata" then
        seen[data] = true
    end

    -- Check if current node is unserializable
    if type(data) == "userdata" then
        local valueType = Ext.Types.GetValueType(data)
        if valueType == "Entity" then
            SPrint("Found Entity at path: %s", path)
        else
            local objectType = Ext.Types.GetObjectType(data)
            local ti = Ext.Types.GetTypeInfo(objectType)
            if ti and (ti.Kind == "Array" or ti.Kind == "Set" or ti.Kind == "Map") then
                SPrint("Found %s at path: %s", ti.Kind, path)
            end
        end
    end

    -- Recurse through table entries
    if type(data) == "table" then
        for k,v in pairs(data) do
            local newPath = string.format("%s.%s", path, tostring(k))
            if type(v) == "table" or type(v) == "userdata" then
                Helpers.Net.CombForUnserializable(v, seen, newPath)
            end
        end
    -- Handle userdata that can be iterated
    elseif type(data) == "userdata" and not isUserdataEdgecase(data) then
        local objectType = Ext.Types.GetObjectType(data)
        local ti = Ext.Types.GetTypeInfo(objectType)
        if ti then
            if ti.Kind == "Array" then
                for i = 1, #data do
                    local v = data[i]
                    if v ~= nil then
                        local newPath = string.format("%s[%d]", path, i)
                        if type(v) == "table" or type(v) == "userdata" then
                            Helpers.Net.CombForUnserializable(v, seen, newPath)
                        end
                    end
                end
            elseif ti.Kind == "Set" then
                for i = 1, #data do
                    local v = Ext.Types.GetHashSetValueAt(data, i)
                    if v ~= nil then
                        local newPath = string.format("%s[%d]", path, i)
                        if type(v) == "table" or type(v) == "userdata" then
                            Helpers.Net.CombForUnserializable(v, seen, newPath)
                        end
                    end
                end
            elseif ti.Kind == "Map" then
                for k,v in pairs(data) do
                    local newPath = string.format("%s[%s]", path, tostring(k))
                    if type(v) == "table" or type(v) == "userdata" then
                        Helpers.Net.CombForUnserializable(v, seen, newPath)
                    end
                end
            end
        end
    end
end