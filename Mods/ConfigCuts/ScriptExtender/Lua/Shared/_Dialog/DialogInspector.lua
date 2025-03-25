---@class DialogInspector
---@field Window ExtuiWindow
---@field RefreshButton ExtuiButton
---@field DialogContainer ExtuiChildWindow
---@field CurrentDialog Dialog
DialogInspector = {
    Ready = false
}

--- Create UI
local function init()
    if not DialogInspector.Window then
        local viewport = Ext.IMGUI.GetViewportSize()
        local sizeInit = {600, 550}
        local sizeMax = {math.floor(viewport[1]*0.5), math.floor(viewport[2]*0.85)}
        local win = Ext.IMGUI.NewWindow("Dialog Inspector")
        win.IDContext = "ConfigCutsDialogInspector"
        win.Open = true
        win.Closeable = true
        -- win.AlwaysAutoResize = true
        win:SetSize(sizeInit, "Always")
        win:SetStyle("WindowMinSize", sizeInit[1], sizeInit[2])
        win:SetSizeConstraints(sizeInit, sizeMax)

        DialogInspector.Window = win
        DialogInspector:Init()
    end
    -- Ext.IMGUI.EnableDemo(true)
end
Ext.Events.SessionLoaded:Subscribe(init)
Ext.Events.ResetCompleted:Subscribe(init)

function DialogInspector:Init()
    local b = self.Window:AddButton("Refresh Dialogs")
    self.RefreshButton = b
    self.RefreshButton:SetColor("Button", Imgui.Colors.MediumAquamarine)
    self.DialogContainer = self.Window:AddChildWindow("DialogChildWin")
    self.DialogContainer:SetSize({580, 500}, "Always")
    self.DialogContainer:SetContentSize({580, 500})
    b.OnClick = function()
        -- Clean old
        self.CurrentDialog = nil
        self.RefreshButton:SetColor("Button", Imgui.Colors.DarkOrange)
        RPrint("Requesting current dialog from server.")
        -- Get new
        local returnHandler = function(reply)
            self.RefreshButton:SetColor("Button", Imgui.Colors.MediumAquamarine)
            STest("Received from server:")
            RPrint(reply)
            if reply and reply.DialogManager and reply.DialogManager.DialogData then
                self.CurrentDialog = Dialog.CreateFromNetMessage(reply.DialogManager, self.DialogContainer)
                RPrintS(self.CurrentDialog)
                self.CurrentDialog:RefreshUI()
            else
                SWarn("Hmm. Server sent no dialogs.")
            end
        end
        DialogNetChannel:RequestToServer({ Request = "GetDialogManager" }, returnHandler)
    end
    b:Tooltip():AddText("Refresh the current dialog in the dialog manager.")

    self.Ready = true
end

-- TODO lookup guids with Ext.Resource.Get(dialogGuid, "Dialog"|"Timeline")