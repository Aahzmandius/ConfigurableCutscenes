---@class ConfigCutsUI
---@field Window ExtuiWindow
ConfigCutsUI = {
    Ready = false
}

--- Create UI
local function init()
    if not ConfigCutsUI.Window then
        local viewport = Ext.IMGUI.GetViewportSize()
        local sizeInit = {600, 550}
        -- local sizeMax = {math.floor(viewport[1]*0.5), math.floor(viewport[2]*0.85)}
        local win = Ext.IMGUI.NewWindow("Configurable Cutscenes")
        win.IDContext = "ConfigCutsWin"
        win.Open = true
        win.Closeable = true
        -- win:SetSize(sizeInit, "FirstUseEver")
        win:SetStyle("WindowMinSize", sizeInit[1], sizeInit[2])
        -- win:SetSizeConstraints(sizeInit, sizeMax)
        win.AlwaysAutoResize = true

        ConfigCutsUI.Window = win
        ConfigCutsUI:Init()
    end
end
Ext.Events.SessionLoaded:Subscribe(init)
Ext.Events.ResetCompleted:Subscribe(init) -- just in case, idk
-- Insert into MCM when MCM is ready
Ext.RegisterNetListener("MCM_Server_Send_Configs_To_Client", function(_, payload)
    Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Configurable Cutscenes", function(treeParent)
        treeParent:AddDummy(20,1)
        local openButton = treeParent:AddButton(Ext.Loca.GetTranslatedString("h1efb00da5db94b0e911fcffaa8e62b653469", "Open/Close"))

        openButton.OnClick = ConfigCutsUI.OpenClose

        openButton:Tooltip():AddText(Ext.Loca.GetTranslatedString("Opens the main Configurable Cutscenes UI.","Opens the main Configurable Cutscenes UI."))
    end)
end)

-- Setup for OnClick shorthand
function ConfigCutsUI.OpenClose(self) self = ConfigCutsUI; if self.Ready then self.Window.Open = not self.Window.Open end end
function ConfigCutsUI.OpenCloseSettings(self) self = ConfigCutsUI; if self.Ready then self.SettingsWindow.Open = not self.SettingsWindow.Open end end

function ConfigCutsUI:Init()
    if not self.Ready then
        self:GenerateSettingsWindow()
        self:CreateMenus()
        self:GenerateMainUI()

        self.Window.OnClose = function()
            if self.OnClose then self:OnClose() end
        end

        self.Ready = true
    end
end

function ConfigCutsUI:GenerateSettingsWindow()
    if not self.SettingsWindow then
        -- General window setup
        local viewport = Ext.IMGUI.GetViewportSize()
        local sizeInit = {600, 550}
        local sizeMax = {math.floor(viewport[1]*0.5), math.floor(viewport[2]*0.85)}
        local win = Ext.IMGUI.NewWindow("Configurable Cutscenes: Settings")
        win.IDContext = "ConfigCutsWinSettings"
        win.Open = false
        win.Closeable = true
        win:SetSize(sizeInit, "FirstUseEver")
        win:SetStyle("WindowMinSize", sizeInit[1], sizeInit[2])
        win:SetSizeConstraints(sizeInit, sizeMax)
        win.AlwaysAutoResize = true

        self.SettingsWindow = win

        -- Setting contents
        local placeholderText = win:AddBulletText("Placeholder")
        local t = win:AddText("Another placeholder.")
    end
end

function ConfigCutsUI:CreateMenus()
    -- Create main menu
    local windowMainMenu = self.Window:AddMainMenu()
    local fileMenu = windowMainMenu:AddMenu(Ext.Loca.GetTranslatedString("h994c9e9e54d041d19d3d300f6b2c027fcf4g", "File"))
    local settingsMenu = fileMenu:AddItem(Ext.Loca.GetTranslatedString("h01e7a1560dae4011a92d7f0872f55910cb0a", "Settings"))
    local closeButton = fileMenu:AddItem(Ext.Loca.GetTranslatedString("hee75fb6fc8c9410ab7baf106879bd2ed0236", "Close"))

    settingsMenu.OnClick = self.OpenCloseSettings
    closeButton.OnClick = function ()
        self.Window.Open = false
    end
end
function ConfigCutsUI:GenerateMainUI()
    if DialogLookup.Ready then
        local combo = self.Window:AddCombo("Dialogs")
        local startButton = self.Window:AddButton("Start Dialog")
        local forceStopButton = self.Window:AddButton("Force Stop Dialog")
        forceStopButton.SameLine = true

        -- Dialog Dropdown
        local options = {}
        local optionsMap = {}
        for k,dialog in pairs(DialogLookup.AllDialogs) do
            local mapID = string.format("%s_%s", dialog.Name, string.sub(dialog.ID, 1, 6))

            table.insert(options, mapID)
            optionsMap[mapID] = dialog.ID
        end
        table.sort(options)
        combo.Options = options
        self.DialogMap = optionsMap
        self.MainDropdown = combo
        combo.OnChange = function()
            local newDialogID = self.DialogMap[Imgui.Combo.GetSelected(combo)]
            self:DisplayDialog(newDialogID)
        end

        -- Dialog Display
        local childGroup = self.Window:AddGroup("DialogDisplay")
        self.DialogDisplay = childGroup

        startButton.OnClick = function()
            local dialogID = self.DialogMap[Imgui.Combo.GetSelected(combo)]
            if dialogID then
                local dialog = DialogLookup.AllDialogs[dialogID]
                if dialog then
                    local firstNullSpeaker = 1
                    -- :crimge: plz clean, no time
                    for i, speaker in ipairs(dialog.Speakers) do
                        if speaker == NULLUUID then
                            firstNullSpeaker = i
                            break
                        end
                    end
                    local char1 = firstNullSpeaker == 1 and _C().Uuid.EntityUuid or dialog.Speakers[1]
                    local char2 = firstNullSpeaker == 2 and _C().Uuid.EntityUuid or dialog.Speakers[2]
                    local char3 = firstNullSpeaker == 3 and _C().Uuid.EntityUuid or dialog.Speakers[3]
                    local char4 = firstNullSpeaker == 4 and _C().Uuid.EntityUuid or dialog.Speakers[4]
                    local char5 = firstNullSpeaker == 5 and _C().Uuid.EntityUuid or dialog.Speakers[5]
                    local char6 = firstNullSpeaker == 6 and _C().Uuid.EntityUuid or dialog.Speakers[6]
                    Cutscene:New({
                        Data = {
                            CutsceneStartDialog:New({
                                DialogID = dialogID,
                                Char1 = char1,
                                Char2 = char2,
                                Char3 = char3,
                                Char4 = char4,
                                Char5 = char5,
                                Char6 = char6,
                            }),
                        }
                    }):Request()
                else
                    SWarn("Dialog not found: %s", dialogID)
                end
            end
        end
        forceStopButton.OnClick = function()
            local dialogID = self.DialogMap[Imgui.Combo.GetSelected(combo)]
            if dialogID then
                Cutscene:New({
                    Data = {
                        CutsceneForceStopDialog:New({
                            DialogID = dialogID,
                            Character = _C().Uuid.EntityUuid,
                        }),
                    }
                }):Request()
            end
        end
    else
        SWarn("DialogLookup wasn't ready, where is the what. Help. help.")
    end
end
function ConfigCutsUI:DisplayDialog(dialogID)
    Imgui.ClearChildren(self.DialogDisplay)
    local dialog = DialogLookup.AllDialogs[dialogID]
    if dialog then
        local title = self.DialogDisplay:AddSeparatorText(dialog.Name)
        title:SetColor("Text", Imgui.Colors.DarkOrange)
        local dialogIDText = self.DialogDisplay:AddText(("Dialog ID: %s"):format(dialog.ID))
        local speakerCount = self.DialogDisplay:AddText(("Speakers: %s"):format(dialog.SpeakerCount))
        local speakers = self.DialogDisplay:AddText("Speakers:")
        for i, speaker in ipairs(dialog.Speakers) do
            local speakerText = self.DialogDisplay:AddBulletText(("%s. %s"):format(i, speaker))
        end
    else
        SWarn("Dialog not found: %s", dialogID)
    end
end


--- Mods.ConfigCuts.testDummy()
function testDummy()
    local playerID = _C().Uuid.EntityUuid
    local origin = Data.Origins.Shadowheart.Uuid
    local testCutscene = Cutscene:New({
        Data = {
            -- CutsceneTeleportAct:New({Act = "Act1"}),
            -- CutsceneTeleportLocation:New({Location = "1bf2ce97-e32d-49d9-8497-3dd64413bca3"}),
            -- CutsceneFlagSet:New({Flag = "0", Object = playerID}),
            -- CutsceneTagSet:New({Tag = "YES", Object = origin}),
            CutsceneSetRomance:New({
                Character = playerID,
                Origin = origin,
                Relationship = true,
            }),
            CutsceneStartDialog:New({
                -- DialogID = "bfb6d8f8-12cf-891c-4f9c-f59113a1d32a",
                DialogID = "CAMP_Shadowheart_Nightfall_SD_ROM_0a86b0b6-4ebc-d1f1-d537-715983e22c26",
                -- DialogID = "CAMP_Laezel_CRD_SecondNight_3907a519-e333-1ea6-6dcf-0b9f6ba872b5",
                -- DialogID = "CAMP_Mizora_SD_ROM_27220d79-2ae3-0262-209b-3e91e1b42f88",
                -- DialogID = "CAMP_GoblinHuntCelebration_SC_NightWithLaezel_1f65b94b-252d-b56e-e812-478a7ff803a8",
                -- DialogID = "TUT_Start_Laezel_c62d7e26-beb5-0afe-becd-68a25c7f4314",
                -- DialogID = "CAMP_DaisyCourseCorrection_AVD_ab34160d-e291-d961-9488-811fa68f2101",
                -- DialogID = "CAMP_Astarion_CRD_ScarReading_c3b2bc4f-46a5-1b25-f2aa-288dbbf47f43",
                -- Char1 = origin,
                Char1 = playerID,
            }),
            -- CutsceneTagClear:New({Tag = "0", Object = playerID})
        }
    })
    STest("Testing request...")
    RPrint(testCutscene)
    testCutscene:Request()
end

Ext.RegisterConsoleCommand("dialog", function(_,arg1)
    local num = tonumber(arg1)
    if num then
        local dialog = Ext.Resource.Get(Ext.Resource.GetAll("Dialog")[num], "Dialog") --[[@as ResourceDialogResource]]
        if dialog then
            SPrint("Attempting to play dialog:")
            RPrint(dialog)
            Cutscene:New({
                Data = {
                    CutsceneStartDialog:New({
                        DialogID = dialog.Guid,
                        Char1 = _C().Uuid.EntityUuid,
                        Char2 = Data.Origins.Laezel.Uuid,
                        Char3 = Data.Origins.Gale.Uuid,
                    }),
                }
            }):Request()
        end
    else
        if Helpers.Format.IsValidUUID(arg1) then
            local dialog = Ext.Resource.Get(arg1, "Dialog")
            if dialog then
                SPrint("Attempting to play dialog:")
                RPrint(dialog)
                Cutscene:New({
                    Data = {
                        CutsceneStartDialog:New({
                            DialogID = dialog.Guid,
                            Char1 = _C().Uuid.EntityUuid,
                            Char2 = Data.Origins.Laezel.Uuid,
                            Char3 = Data.Origins.Gale.Uuid,
                        }),
                    }
                }):Request()
            else
                SWarn("Invalid dialog.")
            end
        else
            SWarn("Invalid uuid.")
        end
    end
end)
