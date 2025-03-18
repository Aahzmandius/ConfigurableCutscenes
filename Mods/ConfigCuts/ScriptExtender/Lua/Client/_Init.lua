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
        local sizeMax = {math.floor(viewport[1]*0.5), math.floor(viewport[2]*0.85)}
        local win = Ext.IMGUI.NewWindow("Configurable Cutscenes")
        win.IDContext = "ConfigCutsWin"
        win.Open = false
        win.Closeable = true
        win.AlwaysAutoResize = true
        win:SetSize(sizeInit, "FirstUseEver")
        win:SetStyle("WindowMinSize", sizeInit[1], sizeInit[2])
        win:SetSizeConstraints(sizeInit, sizeMax)

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
    self.Window:AddBulletText("More Placeholders.")
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
