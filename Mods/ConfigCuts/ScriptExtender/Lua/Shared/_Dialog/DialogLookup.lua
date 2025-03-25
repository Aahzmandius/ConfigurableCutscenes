---@class SpeakerList : {[1]: Guid, [2]: Guid, [3]: Guid, [4]: Guid, [5]: Guid, [6]: Guid}

---@class ParsedDialog
---@field ID Guid
---@field Name string?
---@field SpeakerCount integer
---@field Speakers SpeakerList

---@class DialogLookup: MetaClass
---@field AllDialogs table<Guid, ParsedDialog>
---@field Ready boolean
DialogLookup = _Class:Create("DialogLookup", nil, {
    Ready = false
})

function DialogLookup:New()
    SWarn("DialogLookup:New() called, but this class is not meant to be instantiated.")
    return self
end
function DialogLookup:Init()
    if self.Ready then return SWarn("Already initialized, called multiple times.") end

    -- Parse from CSV's into uh, better/consolidated format
    local data = Helpers.CSV.ParseFromFile("Mods/ConfigCuts/ScriptExtender/Lua/Shared/Data/testData.csv")
    if data then
        SPrint("Parsing test data into DialogLookup")
        local function parseRow(row)
            local speakerCount = tonumber((row["Number of Speakers"]):match("^%s*(%d+)%s*,"))
            if not speakerCount then SWarn("Speaker Count not a number: %s", row["Number of Speakers"]) speakerCount = 0 end

            local speaker1 = row["Character Code 1"]
            local speaker2 = row["Character Code 2"]
            local speaker3 = row["Character Code 3"]
            local speaker4 = row["Character Code 4"]
            local speaker5 = row["Character Code 5"]
            local speaker6 = row["Character Code 6"]
            speaker1 = speaker1 and speaker1 ~= "" and speaker1 or NULLUUID
            speaker2 = speaker2 and speaker2 ~= "" and speaker2 or NULLUUID
            speaker3 = speaker3 and speaker3 ~= "" and speaker3 or NULLUUID
            speaker4 = speaker4 and speaker4 ~= "" and speaker4 or NULLUUID
            speaker5 = speaker5 and speaker5 ~= "" and speaker5 or NULLUUID
            speaker6 = speaker6 and speaker6 ~= "" and speaker6 or NULLUUID
            local speakers = {
                speaker1,
                speaker2,
                speaker3,
                speaker4,
                speaker5,
                speaker6,
            } --[[@as SpeakerList]]
            local newDialog = {
                ID = row["Scene Code"], --:cringe:
                Name = row["Scene Name"],
                SpeakerCount = speakerCount,
                Speakers = speakers,
            }
            return newDialog
        end
        self.AllDialogs = {}
        for i, r in ipairs(data.Rows) do
            local dialog = parseRow(r)
            self.AllDialogs[dialog.ID] = dialog
        end
    end
        
    self.Ready = true
end

if not DialogLookup.Ready then
    DialogLookup:Init()
end
return DialogLookup