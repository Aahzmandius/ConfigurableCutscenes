-- Wrapper for serializable CutsceneData that includes functionality
---@class Cutscene: MetaClass
---@field Data CutsceneData[] # ordered list of data operations to process for the cutscene
Cutscene = _Class:Create("Cutscene", nil, {
    Data = {}
})

local CutsceneRequest = Ext.Net.CreateChannel(ModuleUUID, "ConfigCuts.CutsceneRequest")

if Ext.IsClient() then
    -- Client only, call to request cutscene after Data is set
    function Cutscene:Request()
        -- Send the message to server
        SDebug("Requesting a cutscene...")
        CutsceneRequest:SendToServer(self.Data)
    end
else
    -- Server only, called when server receives a cutscene request
    function Cutscene:Execute()
        SDebug("Executing...")
        for _, operation in ipairs(self.Data) do
            if CutsceneAction[operation.Type] then
                SDebug(" - "..operation.Type)
                CutsceneAction:Execute(operation)
            end
        end
    end
    -- Sets the netchannel handler for CutsceneRequest on the server, for when a message is received
    CutsceneRequest:SetHandler(function(cutsceneData)
        SDebug("Cutscene received:")
        RPrint(cutsceneData)
        ---@type Cutscene
        local cutscene = Cutscene:New({Data = cutsceneData})
        cutscene:Execute()
    end)
end