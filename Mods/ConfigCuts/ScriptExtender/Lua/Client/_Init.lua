--- Mods.ConfigCuts.testDummy()
function testDummy()
    local playerID = _C().Uuid.EntityUuid
    local origin = Data.Origins.Astarion.Uuid
    local testCutscene = Cutscene:New({
        Data = {
            -- CutsceneTeleportAct:New({Act = "Act1"}),
            -- CutsceneTeleportLocation:New({Location = "1bf2ce97-e32d-49d9-8497-3dd64413bca3"}),
            -- CutsceneFlagSet:New({Flag = "0", Object = playerID}),
            -- CutsceneTagSet:New({Tag = "YES", Object = origin}),
            CutsceneStartDialog:New({
                -- DialogID = "camp_daisycoursecorrection_avd_ab34160d-e291-d961-9488-811fa68f2101",
                DialogID = "CAMP_Astarion_CRD_ScarReading_c3b2bc4f-46a5-1b25-f2aa-288dbbf47f43",
                Char1 = origin,
                Char2 = playerID,
            }),
            -- CutsceneTagClear:New({Tag = "0", Object = playerID})
        }
    })
    STest("Testing request...")
    RPrint(testCutscene)
    testCutscene:Request()
end