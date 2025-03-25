require("Shared._Dialog.DialogLookup")
require("Shared._Dialog.DialogNode")

DialogNetChannel = Ext.Net.CreateChannel(ModuleUUID, "ConfigCuts.DialogNetChannel")
if Ext.IsClient() then
    require("Shared._Dialog.DialogInspector")
else
    DialogNetChannel:SetRequestHandler(function(args)
        if args.Request == "GetDialogManager" then
            local dm = Ext.Utils.GetDialogManager()
            if dm then
                SPrint("Received request for DialogManager.")
                local firstDialog
                for _,dialog in pairs(dm.Dialogs) do
                    firstDialog = dialog
                    RPrint(("Sending Dialog #%s"):format(_))
                    break
                end
                if not firstDialog then
                    return SWarn("Requested dialog, but no dialogs found.")
                end
    
                local serverDialog = Dialog.CreateFromDlg(firstDialog)
                
                local sanitized = Helpers.Net.SanitizeForNet(serverDialog)
                RPrint("Sanitized DialogManager:")
                RPrintM(sanitized)
                SDebug("=========== Unsanitized DialogManager ===========")
                Helpers.Net.CombForUnserializable(serverDialog)
                SDebug("==== Combing sanitized for uncaught problems ====")
                Helpers.Net.CombForUnserializable(sanitized)
                SDebug("================ Done combing ===================")
                -- RPrintS(sanitized.Speakers)
                return {
                    DialogManager = sanitized
                }
            else
                SWarn("DialogManager not found, cannot complete request.")
            end
        end
    end)
end