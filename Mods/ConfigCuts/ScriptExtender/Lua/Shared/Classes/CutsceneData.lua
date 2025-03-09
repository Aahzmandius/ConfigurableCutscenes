---@enum CutsceneActionType
CutsceneActionType = {
    TeleportAct = "TeleportAct",
    TeleportLocation = "TeleportLocation",
    FlagSet = "FlagSet",
    FlagClear = "FlagClear",
    TagSet = "TagSet",
    TagClear = "TagClear",
    SetRomance = "SetRomance",
    StartDialog = "StartDialog",
    -- "RevertRomance", -- TODO
}

---@class CutsceneData: MetaClass
---@field Type CutsceneActionType
CutsceneData = _Class:Create("CutsceneData", nil, {})

function CutsceneData:Init()
    if not self.Type then SWarn("CutsceneData incorrectly initialized, provide CutsceneActionType when constructing.") end
    self.Type = self.Type
end

---@class CutsceneTeleportAct:CutsceneData
---@field Act string # Act to teleport to
CutsceneTeleportAct = CutsceneData:New({
    Type = CutsceneActionType.TeleportAct,
    Act = "Act1", -- Default
})

---@class CutsceneTeleportLocation:CutsceneData
---@field Location Guid # Location guid to teleport to within a region
CutsceneTeleportLocation = CutsceneData:New({
    Type = CutsceneActionType.TeleportLocation,
    Location = NULLUUID, -- Default
})

---@class CutsceneFlagSet:CutsceneData
---@field Flag Guid #flag id to set
---@field Object Guid #object to set flag on
---@field Value integer #optional integer value to set flag to, usually 0-1
CutsceneFlagSet = CutsceneData:New({
    Type = CutsceneActionType.FlagSet,
    Flag = NULLUUID, --
    Object = NULLUUID, --
    Value = 0,
})

---@class CutsceneFlagClear:CutsceneData
---@field Flag Guid #flag id to clear
---@field Object Guid #object to clear flag on
CutsceneFlagClear = CutsceneData:New({
    Type = CutsceneActionType.FlagClear,
    Flag = NULLUUID,
    Object = NULLUUID,
})

---@class CutsceneTagSet:CutsceneData
---@field Tag Guid #tag id to set
---@field Object Guid #object to set tag on
CutsceneTagSet = CutsceneData:New({
    Type = CutsceneActionType.TagSet,
    Tag = NULLUUID, --
    Object = NULLUUID, --
})

---@class CutsceneTagClear:CutsceneData
---@field Tag Guid #tag id to clear
---@field Object Guid #object to clear tag on
CutsceneTagClear = CutsceneData:New({
    Type = CutsceneActionType.TagClear,
    Tag = NULLUUID,
    Object = NULLUUID,
})

---@class CutsceneSetRomance:CutsceneData
---@field Character Guid #player character
---@field Origin Guid #origin character to romance
---@field Relationship boolean? -- initial relationship
---@field Dating boolean? -- partnered
CutsceneSetRomance = CutsceneData:New({
    Type = CutsceneActionType.SetRomance,
    Character = NULLUUID,
    Origin = NULLUUID,
})

---@class CutsceneStartDialog:CutsceneData
---@field DialogID DIALOGRESOURCE
---@field Char1 Guid
---@field Char2 Guid?
---@field Char3 Guid?
---@field Char4 Guid?
---@field Char5 Guid?
---@field Char6 Guid?
CutsceneStartDialog = CutsceneData:New({
    Type = CutsceneActionType.StartDialog,
    DialogID = NULLUUID,
    Char1 = NULLUUID,
})
function CutsceneStartDialog:Init()
    self.Type = self.Type
    self.DialogID = self.DialogID
    self.Char1 = self.Char1
    self.Char2 = self.Char2 or OSINULL
    self.Char3 = self.Char3 or OSINULL
    self.Char4 = self.Char4 or OSINULL
    self.Char5 = self.Char5 or OSINULL
    self.Char6 = self.Char6 or OSINULL
end