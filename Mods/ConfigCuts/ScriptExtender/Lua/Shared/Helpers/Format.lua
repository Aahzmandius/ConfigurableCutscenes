Helpers = Helpers or {}
Helpers.Format = Helpers.Format or {}

---@return Guid
function Helpers.Format.CreateUUID()
---@diagnostic disable-next-line: redundant-return-value
    return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function (c)
        return string.format("%x", c == "x" and Ext.Math.Random(0, 0xf) or Ext.Math.Random(8, 0xb))
    end)
end

---Checks if a given string is a valid UUID (any UUID format, not just v4)
---@param uuid string
---@return boolean
function Helpers.Format.IsValidUUID(uuid)
    local pattern = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$" --:deadge: lua
    local match = string.match(uuid, pattern)
    return type(match) == "string"
end

---@param object Guid|EntityHandle
---@return string
function Helpers.Format.GetDisplayName(object)
    local name
    --@type EntityHandle
    local entity = type(object) == "string" and Ext.Entity.Get(object) or object
    if entity ~= nil and entity.DisplayName ~= nil then
        name = entity.DisplayName.Name:Get() or "Unknown"
    end
    return name
end

-- string.find but not case sensitive
--@param str1 string       - string 1 to compare
--@param str2 string       - string 2 to compare
function Helpers.Format.CaseInsensitiveSearch(str1, str2)
    str1 = string.lower(str1)
    str2 = string.lower(str2)
    local result = string.find(str1, str2, 1, true)
    return result ~= nil
end

--- @param e EntityHandle
function Helpers.GetEntityName(e)
    if e == nil then return nil end
    if Ext.Types.GetValueType(e) ~= "Entity" then return nil end

    if e.CustomName ~= nil then
        return e.CustomName.Name
    elseif e.DisplayName ~= nil then
        return Ext.Loca.GetTranslatedString(e.DisplayName.NameKey.Handle.Handle)
    elseif e:HasRawComponent("ls::TerrainObject") then
        return "Terrain"
    elseif e.GameObjectVisual ~= nil then
        return Ext.Template.GetTemplate(e.GameObjectVisual.RootTemplateId).Name
    elseif e.Visual ~= nil and e.Visual.Visual ~= nil and e.Visual.Visual.VisualResource ~= nil then
        local name = ""
        if e:HasRawComponent("ecl::Scenery") then
            name = name .. "(Scenery)"
        end
        local visName = "Unknown"
        -- Jank to get last part
        for part in string.gmatch(e.Visual.Visual.VisualResource.Template, "[a-zA-Z0-9_.]+") do
            visName = part
        end
        return name..visName
    elseif e.SpellCastState ~= nil then
        return "Spell Cast " .. e.SpellCastState.SpellId.Prototype
    elseif e.ProgressionMeta ~= nil then
        --- @type ResourceProgression
        local progression = Ext.StaticData.Get(e.ProgressionMeta.Progression, "Progression")
        return "Progression " .. progression.Name
    elseif e.BoostInfo ~= nil then
        return "Boost " .. e.BoostInfo.Params.Boost
    elseif e.StatusID ~= nil then
        return "Status " .. e.StatusID.ID
    elseif e.Passive ~= nil then
        return "Passive " .. e.Passive.PassiveId
    elseif e.InterruptData ~= nil then
        return "Interrupt " .. e.InterruptData.Interrupt
    elseif e.InventoryIsOwned ~= nil then
        return "Inventory of " .. GetEntityName(e.InventoryIsOwned.Owner)
    elseif e.Uuid ~= nil then
        return e.Uuid.EntityUuid
    else
        return nil
    end
end

-- Mapping table for common non-English characters to English equivalents
Helpers.Format.NonEnglishCharMap = {
    ["á"] = "a", ["é"] = "e", ["í"] = "i", ["ó"] = "o", ["ú"] = "u",
    ["Á"] = "A", ["É"] = "E", ["Í"] = "I", ["Ó"] = "O", ["Ú"] = "U",
    ["ä"] = "a", ["ë"] = "e", ["ï"] = "i", ["ö"] = "o", ["ü"] = "u",
    ["Ä"] = "A", ["Ë"] = "E", ["Ï"] = "I", ["Ö"] = "O", ["Ü"] = "U",
    ["à"] = "a", ["è"] = "e", ["ì"] = "i", ["ò"] = "o", ["ù"] = "u",
    ["À"] = "A", ["È"] = "E", ["Ì"] = "I", ["Ò"] = "O", ["Ù"] = "U",
    ["â"] = "a", ["ê"] = "e", ["î"] = "i", ["ô"] = "o", ["û"] = "u",
    ["Â"] = "A", ["Ê"] = "E", ["Î"] = "I", ["Ô"] = "O", ["Û"] = "U",
    ["ã"] = "a", ["õ"] = "o", ["ñ"] = "n",
    ["Ã"] = "A", ["Õ"] = "O", ["Ñ"] = "N",
    ["ç"] = "c", ["Ç"] = "C",
    ["ß"] = "ss",
    ["ø"] = "o", ["Ø"] = "O",
    ["å"] = "a", ["Å"] = "A",
    ["æ"] = "ae", ["Æ"] = "AE",
    ["œ"] = "oe", ["Œ"] = "OE",
    -- Cyrillic characters
    ["А"] = "A", ["Б"] = "B", ["В"] = "V", ["Г"] = "G", ["Д"] = "D",
    ["Е"] = "E", ["Ё"] = "E", ["Ж"] = "Zh", ["З"] = "Z", ["И"] = "I",
    ["Й"] = "I", ["К"] = "K", ["Л"] = "L", ["М"] = "M", ["Н"] = "N",
    ["О"] = "O", ["П"] = "P", ["Р"] = "R", ["С"] = "S", ["Т"] = "T",
    ["У"] = "U", ["Ф"] = "F", ["Х"] = "Kh", ["Ц"] = "Ts", ["Ч"] = "Ch",
    ["Ш"] = "Sh", ["Щ"] = "Shch", ["Ъ"] = "", ["Ы"] = "Y", ["Ь"] = "",
    ["Э"] = "E", ["Ю"] = "Yu", ["Я"] = "Ya",
    ["а"] = "a", ["б"] = "b", ["в"] = "v", ["г"] = "g", ["д"] = "d",
    ["е"] = "e", ["ё"] = "e", ["ж"] = "zh", ["з"] = "z", ["и"] = "i",
    ["й"] = "i", ["к"] = "k", ["л"] = "l", ["м"] = "m", ["н"] = "n",
    ["о"] = "o", ["п"] = "p", ["р"] = "r", ["с"] = "s", ["т"] = "t",
    ["у"] = "u", ["ф"] = "f", ["х"] = "kh", ["ц"] = "ts", ["ч"] = "ch",
    ["ш"] = "sh", ["щ"] = "shch", ["ъ"] = "", ["ы"] = "y", ["ь"] = "",
    ["э"] = "e", ["ю"] = "yu", ["я"] = "ya",
    -- Misc others
    ["ą"] = "a", ["ć"] = "c", ["ę"] = "e", ["ł"] = "l", ["ń"] = "n",
    ["ś"] = "s", ["ź"] = "z", ["ż"] = "z",
    ["Ą"] = "A", ["Ć"] = "C", ["Ę"] = "E", ["Ł"] = "L", ["Ń"] = "N",
    ["Ś"] = "S", ["Ź"] = "Z", ["Ż"] = "Z",
    ["ő"] = "o", ["ű"] = "u", ["Ő"] = "O", ["Ű"] = "U",
    ["ă"] = "a", ["ș"] = "s", ["ț"] = "t",
    ["Ă"] = "A", ["Ș"] = "S", ["Ț"] = "T",
}

-- Removes illegal characters from a filename, and replaces common non-English characters with English equivalents.
-- @param str Filename string to be sanitized.
-- @return Sanitized filename string.
function Helpers.Format.SanitizeFileName(str)
    
    -- Replace non-English characters with their English equivalents
    str = string.gsub(str, ".", function(c)
        return Helpers.Format.NonEnglishCharMap[c] or c
    end)
    
    -- Remove control characters and basic illegal characters
    str = string.gsub(str, "[%c<>:\"/\\|%?%*]", "") -- Removes:     < > : " / \ | ? *

    -- Trim whitespace from the beginning and end of the string
---@diagnostic disable-next-line: param-type-mismatch
    str = str:trim()

    return str
end