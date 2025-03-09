if not Ext.IsServer() then return end

local debug = true
---@class CutsceneAction
---@field TeleportAct fun(act:string)
---@field TeleportLocation fun(location:Guid)
---@field FlagSet fun(flag:Guid, object:Guid, value:integer)
---@field FlagClear fun(flag:Guid, object:Guid)
---@field TagSet fun(tag:Guid, object:Guid)
---@field TagClear fun(tag:Guid, object:Guid)
---@field SetRomance fun(char1:Guid, origin:Guid, relationship:boolean, dating:boolean)
---@field StartDialog fun(dialogID:DIALOGRESOURCE, char1:Guid, char2:Guid, char3:Guid, char4:Guid, char5:Guid, char6:Guid)
-- -@field RevertRomance fun() --TODO
CutsceneAction = {
    TeleportAct = function(act)
        if debug then SDebug("  Act: %s", act) end
        Osi.PROC_Debug_TeleportToAct(act)
    end,
    TeleportLocation = function(location)
        if debug then SDebug("  Location: %s", location) end
        Osi.PROC_TeleportPartiesTo(location, "")
    end,
    FlagSet = function(flag, object, value)
        if debug then SDebug("  Flag: %s, Object: %s (%s)", flag, Helpers.Format.GetDisplayName(object), object, value and "\n  Value: "..tostring(value) or "") end
        Osi.SetFlag(flag, object, value or 0)
    end,
    FlagClear = function(flag, object)
        if debug then SDebug("  Flag: %s, Object: %s (%s)", flag, Helpers.Format.GetDisplayName(object), object) end
        Osi.ClearFlag(flag, object)
    end,
    TagSet = function(tag, object)
        if debug then SDebug("  Tag: %s, Object: %s (%s)", tag, Helpers.Format.GetDisplayName(object), object) end
        Osi.SetTag(object, tag)
    end,
    TagClear = function(tag, object)
        if debug then SDebug("  Tag: %s,  Object: %s (%s)", tag, Helpers.Format.GetDisplayName(object), object) end
        Osi.ClearTag(object, tag)
    end,
    SetRomance = function(char1, origin, relationship, dating)
        if relationship then
            for _, v in pairs(Data.Origins) do
                if v.Uuid == origin and v.RelationshipFlag ~= nil then
                    Osi.SetFlag(v.RelationshipFlag, char1)
                    if debug then
                        SDebug("%s started a relationship with %s (%s).", Helpers.Format.GetDisplayName(char1), Helpers.Format.GetDisplayName(origin), origin)
                    end
                end
            end
        elseif dating then
            for _, v in pairs(Data.Origins) do
                if v.Uuid == origin and v.LoverFlag ~= nil then
                    Osi.SetFlag(v.LoverFlag, char1)
                    if debug then
                        SDebug("%s should now be partnered with %s (%s).", Helpers.Format.GetDisplayName(char1), Helpers.Format.GetDisplayName(origin), origin)
                    end
                end
            end
        end
    end,
    StartDialog = function(dialogID, char1, char2, char3, char4, char5, char6)
        if debug then
            local chars = {}
            if char1 ~= OSINULL then table.insert(chars, char1) end
            if char2 ~= OSINULL then table.insert(chars, char2) end
            if char3 ~= OSINULL then table.insert(chars, char3) end
            if char4 ~= OSINULL then table.insert(chars, char4) end
            if char5 ~= OSINULL then table.insert(chars, char5) end
            if char6 ~= OSINULL then table.insert(chars, char6) end
            local speakers = ""
            for i, speaker in ipairs(chars) do
                speakers = speakers..(("\n   %s. %s (%s)"):format(tostring(i), Helpers.Format.GetDisplayName(speaker), speaker))
            end
            SDebug("  DialogID: %s, Speakers: %s", dialogID, speakers)
        end
        Osi.QRY_StartDialogCustom_Fixed(dialogID , char1, char2, char3, char4, char5, char6, 1, 1, -1, 1 )
    end,
    -- RevertRomance = function()
        -- --PROC_ORI_ClearPartnersIfAvatar(CHARACTER)
        -- --PROC_ORI_ClearPartnersIfCompanion(CHARACTER)
        -- for k, v in pairs(Data.Origins) do
        --     if v.Uuid == e and v.ClearLoverFlags ~= nil then
        --         for i, flag in ipairs(v.ClearLoverFlags) do
        --             Osi.ClearFlag(flag, host)
        --         end
        --         ECPrint("Cleared all relationship flags on %s (%s) for %s.", Helpers.Loca:GetDisplayName(e), e, Helpers.Loca:GetDisplayName(host))
        --     end
        -- end
    -- end,
}

---@param data CutsceneData
function CutsceneAction:Execute(data)
    if data.Type == CutsceneActionType.TeleportAct then
        ---@cast data CutsceneTeleportAct
        self.TeleportAct(data.Act)
    elseif data.Type == CutsceneActionType.TeleportLocation then
        ---@cast data CutsceneTeleportLocation
        self.TeleportLocation(data.Location)
    elseif data.Type == CutsceneActionType.FlagSet then
        ---@cast data CutsceneFlagSet
        self.FlagSet(data.Flag, data.Object, data.Value)
    elseif data.Type == CutsceneActionType.FlagClear then
        ---@cast data CutsceneFlagClear
        self.FlagClear(data.Flag, data.Object)
    elseif data.Type == CutsceneActionType.TagSet then
        ---@cast data CutsceneTagSet
        self.TagSet(data.Tag, data.Object)
    elseif data.Type == CutsceneActionType.TagClear then
        ---@cast data CutsceneTagClear
        self.TagClear(data.Tag, data.Object)
    elseif data.Type == CutsceneActionType.SetRomance then
        ---@cast data CutsceneSetRomance
        self.SetRomance(data.Character, data.Origin, data.Relationship, data.Dating)
    elseif data.Type == CutsceneActionType.StartDialog then
        ---@cast data CutsceneStartDialog
        self.StartDialog(data.DialogID, data.Char1, data.Char2, data.Char3, data.Char4, data.Char5, data.Char6)
    end
end