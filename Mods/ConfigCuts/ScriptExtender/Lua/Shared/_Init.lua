-- Top level basics
require("Shared.MetaClass")
require("Shared.Extensions")
require("Shared.Printer")

-- Static defines
NULLUUID = "00000000-0000-0000-0000-000000000000"
OSINULL = "NULL_00000000-0000-0000-0000-000000000000"

-- Helpers -> Data -> Classes
require("Shared.Helpers._Init")
require("Shared.Data._Init")
require("Shared.Classes.CutsceneData")
require("Shared.Classes.CutsceneAction")
require("Shared.Classes.Cutscene")