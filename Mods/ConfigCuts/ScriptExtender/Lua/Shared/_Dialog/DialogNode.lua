---@alias DialogFlagName "Dialog"|"DialogInstance"|"Global"|"Local"|"Object"|"Party"|"Quest"|"Script"|"Tag"|"User"|"UserShape"

---@class DialogFlag
---@field HasFlagParamInfo boolean
---@field Name DialogFlagName

-- -@class DialogMan
-- -@field FlagDescriptions table<DialogFlagName, DialogFlag>
-- -@field NextInstanceId number # TODO what is this
-- -@field ScriptFlags table #TODO what is this
-- -@field SpeakerGroups table<Guid, DlgSpeakerGroup>
-- -@field DialogToVariable table<int32, Guid>
-- -@field DialogVariables table<Guid, DlgVariable>

---@class Dialog: MetaClass
---@field RuntimeID string # eg. "71"
---@field DialogResourceUUID Guid
---@field InitialDialogResourceUUID Guid
---@field DialogWaitTime number # useful...?
---@field CurrentNodeID Guid #
---@field NodeCustomData table<string, any>
---@field NodeSelection table # TODO complicated
---@field OverriddenDialog Guid?
---@field PlayedDialogs Guid[]
---@field PlayedNestedDialogs Guid[]
---@field PopLevels Guid[] # TODO what is this
---@field QueuedActors any[] # TODO what is
---@field SpeakerLinkings any[] # TODO what is this
---@field Speakers EntityHandle?[] # always 6 slots, null if unused
---@field State number # TODO  what is this
---@field UniqueSpeakerLinkingIndices any[] # TODO what is this
---@field VisitedNodes any[] # TODO what is this
---@field DialogData table<Guid, DialogNodeHolder>
---bools
---@field WasActivated boolean
---@field WorldHadTriggered boolean
---@field UnloadedRequested boolean
---@field StartPaused boolean
---@field SmoothExit boolean
---@field IsAutomatedDialog boolean
---@field CanAttack boolean
---@field AllowDeadSpeakers boolean
---@field IsAllowingJoinCombat boolean
---@field IsBehaviour boolean
---@field IsOnlyPlayers boolean
---@field IsPaused boolean
---@field IsPlayerWatchingTimeline boolean
---@field IsPrivateDialog boolean
---@field IsTimelineEnabled boolean
---@field IsWorld boolean
---IMGUI
---@field Holder ExtuiTreeParent
Dialog = _Class:Create("Dialog", nil, {
})
function Dialog:Init()
end
function Dialog.CreateFromNetMessage(msgDlg, holder)
    local d = Dialog:New({ Holder = holder})
    for k,v in pairs(msgDlg) do
        if k == "DialogData" then
            -- recreate
            d.DialogData = {}
            for dialogKey, dialog in pairs(v) do
                d.DialogData[dialogKey] = DialogNodeHolder.CreateFromNetMessage(dialog)
            end
        else
            d[k] = v
        end
    end
    return d
end

---@param dlg DlgDialogInstance
---@param container ExtuiTreeParent?
function Dialog.CreateFromDlg(dlg, container)
    local d = Dialog:New({
        RuntimeID = dlg.DialogId,
        DialogResourceUUID = dlg.DialogResourceUUID,
        InitialDialogResourceUUID = dlg.InitialDialogResourceUUID,
        DialogWaitTime = dlg.DialogWaitTime,
        CurrentNodeID = dlg.CurrentNode and dlg.CurrentNode.UUID,
        NodeSelection = dlg.NodeSelection,
        OverriddenDialog = dlg.OverriddenDialog,
        PlayedDialogs = dlg.PlayedDialogs,
        PlayedNestedDialogs = dlg.PlayedNestedDialogs,
        PopLevels = dlg.PopLevels,
        QueuedActors = dlg.QueuedActors,
        SpeakerLinkings = dlg.SpeakerLinkings,
        Speakers = dlg.Speakers,
        State = dlg.State,
        UniqueSpeakerLinkingIndices = dlg.UniqueSpeakerLinkingIndices,
        VisitedNodes = dlg.VisitedNodes,

        WasActivated = dlg.WasActivated,
        WorldHadTriggered = dlg.WorldHadTriggered,
        UnloadedRequested = dlg.UnloadRequested,
        StartPaused = dlg.StartPaused,
        SmoothExit = dlg.SmoothExit,
        IsAutomatedDialog = dlg.AutomatedDialog,
        CanAttack = dlg.CanAttack,
        AllowDeadSpeakers = dlg.AllowDeadSpeakers,
        IsAllowingJoinCombat = dlg.IsAllowingJoinCombat,
        IsBehaviour = dlg.IsBehaviour,
        IsOnlyPlayers = dlg.IsOnlyPlayers,
        IsPaused = dlg.IsPaused,
        IsPlayerWatchingTimeline = dlg.IsPlayerWatchingTimeline,
        IsPrivateDialog = dlg.IsPrivateDialog,
        IsTimelineEnabled = dlg.IsTimelineEnabled,
        IsWorld = dlg.IsWorld,
        Holder = container,
    })

    d.NodeCustomData = table.shallowCopy(dlg.NodeCustomData)
    d.DialogData = {}

    for dialogKey, dialog in pairs(dlg.Dialogs) do
        d.DialogData[dialogKey] = DialogNodeHolder.CreateFromDlg(dialog)
    end

    return d
end

-- Client ONLY
if Ext.IsClient() then
    function Dialog:RefreshUI()
        if not self.Holder then return SWarn("Tried to refresh DialogUI with no tree parent set.") end
        Imgui.ClearChildren(self.Holder)
        self.Holder:AddSeparatorText(self.DialogResourceUUID or NULLUUID)
        self.Holder:AddText(("Current Node ID: %s"):format(self.CurrentNodeID or "None"))
        
        local boolHeader = self.Holder:AddCollapsingHeader("Dialog Bools")
        boolHeader.DefaultOpen = false
        self:_DrawBools(boolHeader)
        local nodeChildWin = self.Holder:AddChildWindow("NodeTreeChildWin")
        nodeChildWin:SetSize({580, 500}, "Always")
        local nodeTree = nodeChildWin:AddTree(("Dialog: %s"):format(self.RuntimeID))
        
        for dialogID,dialog in pairs(self.DialogData) do
            local d = nodeTree:AddTree(("Dialog: %s"):format(dialogID))
            dialog:DrawInTree(d)
        end
        
    end
    ---@param parent ExtuiTreeParent
    function Dialog:_DrawBools(parent)
        local lt = parent:AddTable("DialogBool_LayoutTable", 2)
        lt.SizingStretchSame = true
        local r = lt:AddRow()
        local function addCheckbox(name, val)
            local checkbox = r:AddCell():AddCheckbox(name, val)
            checkbox.UserData = { Name = name }
            checkbox.OnChange = function(c)
                -- TODO will have to access through dialogmanager to change, not self
                -- self[name] = c.Checked
            end
        end
        addCheckbox("AllowJoinCombat", self.IsAllowingJoinCombat)
        addCheckbox("CanAttack", self.CanAttack)
        addCheckbox("IsAutomatedDialog", self.IsAutomatedDialog)
        addCheckbox("IsBehavior", self.IsBehaviour)
        addCheckbox("IsDeadSpeakerEnabled", self.AllowDeadSpeakers)
        addCheckbox("IsOnlyPlayers", self.IsOnlyPlayers)
        addCheckbox("IsPaused", self.IsPaused)
        addCheckbox("IsPlayerWatchingTimeline", self.IsPlayerWatchingTimeline)
        addCheckbox("IsPrivateDialog", self.IsPrivateDialog)
        addCheckbox("IsTimelineEnabled", self.IsTimelineEnabled)
        addCheckbox("IsWorld", self.IsWorld)
        addCheckbox("SmoothExit", self.SmoothExit)
        addCheckbox("StartPaused", self.StartPaused)
        addCheckbox("UnloadedRequested", self.UnloadedRequested)
        addCheckbox("WasActivated", self.WasActivated)
        addCheckbox("WorldHadTriggered", self.WorldHadTriggered)
    end
end

---@alias SpeakerSlots "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"|"10"|"11"

---@class DialogNodeHolder: MetaClass # Essentially DlgDialog
---@field UUID Guid
---@field Nodes table<Guid, DialogNode>
---@field Category string
---@field DefaultAddressedSpeakers table<SpeakerSlots, number> # always 12 slots, the entity handle integer...? -1 usually
---@field DefaultSpeakerIndex number # -1...?
---@field PeanutSlots table # TODO what is this
---@field RootNodes table # TODO what is this
---@field SpeakerGroups string[] # single entry...? single string is semicolon separated Guid's
---@field SpeakerMappingIds Guid[]
---@field SpeakerTags string[]
---@field TimelineId Guid
---bools
---@field IsAutomated boolean # nodeHolder.Automated
---@field IsAllowingJoinCombat boolean
---@field IsBehaviour boolean
---@field IsPrivateDialog boolean
---@field IsSFXDialog boolean
---@field IsSubbedDialog boolean
---@field IsSubsAnonymous boolean
DialogNodeHolder = _Class:Create("DialogNodeHolder", nil, {

})
function DialogNodeHolder:Init()
end
function DialogNodeHolder.CreateFromDlg(dlg)
    local d = DialogNodeHolder:New({
        UUID = dlg.UUID,
        Category = dlg.Category,
        DefaultAddressedSpeakers = dlg.DefaultAddressedSpeakers,
        DefaultSpeakerIndex = dlg.DefaultSpeakerIndex,
        PeanutSlots = dlg.PeanutSlots,
        RootNodes = dlg.RootNodes,
        SpeakerGroups = dlg.SpeakerGroups,
        SpeakerMappingIds = dlg.SpeakerMappingIds,
        SpeakerTags = dlg.SpeakerTags,
        TimelineId = dlg.TimelineId,
        IsAutomated = dlg.Automated,
        IsAllowingJoinCombat = dlg.IsAllowingJoinCombat,
        IsBehaviour = dlg.IsBehaviour,
        IsPrivateDialog = dlg.IsPrivateDialog,
        IsSFXDialog = dlg.IsSFXDialog,
        IsSubbedDialog = dlg.IsSubbedDialog,
        IsSubsAnonymous = dlg.IsSubsAnonymous,
        Nodes = {}
    })
    for nodeKey, node in pairs(dlg.Nodes) do
        d.Nodes[nodeKey] = DialogNode.CreateFromDlg(node)
    end
    return d
end
function DialogNodeHolder.CreateFromNetMessage(msg)
    local d = DialogNodeHolder:New({
        UUID = msg.UUID,
        Category = msg.Category,
        DefaultAddressedSpeakers = msg.DefaultAddressedSpeakers,
        DefaultSpeakerIndex = msg.DefaultSpeakerIndex,
        PeanutSlots = msg.PeanutSlots,
        RootNodes = msg.RootNodes,
        SpeakerGroups = msg.SpeakerGroups,
        SpeakerMappingIds = msg.SpeakerMappingIds,
        SpeakerTags = msg.SpeakerTags,
        TimelineId = msg.TimelineId,
        IsAutomated = msg.Automated,
        IsAllowingJoinCombat = msg.IsAllowingJoinCombat,
        IsBehavior = msg.IsBehavior,
        IsPrivateDialog = msg.IsPrivateDialog,
        IsSFXDialog = msg.IsSFXDialog,
        IsSubbedDialog = msg.IsSubbedDialog,
        IsSubsAnonymous = msg.IsSubsAnonymous,
        Nodes = {}
    })
    for nodeKey, node in pairs(msg.Nodes) do
        d.Nodes[nodeKey] = DialogNode.CreateFromDlg(node)
    end
    return d
end

-- Client only
if Ext.IsClient() then
    ---@param parentTree ExtuiTreeParent
    function DialogNodeHolder:DrawInTree(parentTree)
        local t = parentTree:AddTree(self.UUID)
        for key,node in pairs(self.Nodes) do
            node:DrawInTree(t)
        end
    end
end
    
---@class DialogNode: MetaClass
---@field UUID Guid
---@field ConstructorID string # "TagAnswer"|"TagQuestion"|"Jump" etc.
---@field Children Guid[]
---@field IsStub boolean # dlgnode.Stub
---@field AddressedSpeaker number
---@field ApprovalRatingID Guid
-- -@field ParentDialog DlgDialog
---@field CheckFlags DlgFlagCollection
---@field SetFlags DlgFlagCollection
DialogNode = _Class:Create("DialogNode", nil, {
})
function DialogNode:Init()
end

function DialogNode.CreateFromDlg(dlg)
    local d = DialogNode:New({
        UUID = dlg.UUID,
        ConstructorID = dlg.ConstructorID,
        ApprovalRatingID = dlg.ApprovalRatingID,
        CheckFlags = dlg.CheckFlags,
        SetFlags = dlg.SetFlags,
        Children = dlg.Children,
    })
    if pcall(function() return dlg.Stub, dlg.AddressedSpeaker end) then
        d.IsStub = dlg.Stub
        d.AddressedSpeaker = dlg.AddressedSpeaker
    else
        d.IsStub = false  -- if we can't access it, assume it's not a stub
        d.AddressedSpeaker = -42 -- default to -42 if we can't access it
    end
    return d
end

-- Client Only
if Ext.IsClient() then
    function DialogNode:DrawInTree(parentTree)
        local t = parentTree:AddTree(self.UUID)
        t:AddText(("ConstructorID: %s"):format(self.ConstructorID or "None"))
        t:AddText(("IsStub: %s"):format(tostring(self.IsStub or false)))
        t:AddText(("AddressedSpeaker: %s"):format(tostring(self.AddressedSpeaker or -1)))
        t:AddText(("ApprovalRatingID: %s"):format(tostring(self.ApprovalRatingID or "None")))
        t:AddText(("Children: %s"):format(self.Children and #self.Children > 0 and table.concat(self.Children, ", \n\t") or "None"))
        local checkFlagText = ""
        for _,v in pairs(self.CheckFlags) do
            if type(v) ~= "table" then
                checkFlagText = tostring(v)
            else
                --_ == "Flags"
                ---@param flagType DialogFlagName
                ---@param flagGroup DlgFlag[]
                for flagType,flagGroup in pairs(v) do
                    for i, flag in ipairs(flagGroup) do
                        checkFlagText = checkFlagText .. ("(%s) %s : %s\n"):format(flagType, flag.Uuid, flag.Value)
                    end
                end
            end
        end
        t:AddText(("CheckFlags: %s"):format(checkFlagText ~= "" and checkFlagText or "None"))
        local setFlagText = ""
        for _,v in pairs(self.SetFlags) do
            if type(v) ~= "table" then
                setFlagText = tostring(v)
            else
                --_ == "Flags"
                ---@param flagType DialogFlagName
                ---@param flagGroup DlgFlag[]
                for flagType,flagGroup in pairs(v) do
                    for i, flag in ipairs(flagGroup) do
                        setFlagText = setFlagText .. ("(%s) %s : %s\n"):format(flagType, flag.Uuid, flag.Value)
                    end
                end
            end
        end
        t:AddText(("SetFlags: %s"):format(setFlagText ~= "" and setFlagText or "None"))
    end
end