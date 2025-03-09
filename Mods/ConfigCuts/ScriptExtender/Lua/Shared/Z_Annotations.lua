---@meta
---@diagnostic disable

--- Starts a cutscene dialog with given speakers, with low attitude+crime intercepts, blocking interaction in combat, and whether to show attack button
---@overload fun(dialog:DIALOGRESOURCE, speaker1:CHARACTER, speaker2:CHARACTER, allowLowAttitudeIntercept:integer, allowCrimeIntercept:integer, blockInteractiveIfCombat:integer, showAttackButton:integer)
---@overload fun(dialog:DIALOGRESOURCE, speaker1:CHARACTER, speaker2:CHARACTER, speaker3:CHARACTER, allowLowAttitudeIntercept:integer, allowCrimeIntercept:integer, blockInteractiveIfCombat:integer, showAttackButton:integer)
---@overload fun(dialog:DIALOGRESOURCE, speaker1:CHARACTER, speaker2:CHARACTER, speaker3:CHARACTER, speaker4:CHARACTER, allowLowAttitudeIntercept:integer, allowCrimeIntercept:integer, blockInteractiveIfCombat:integer, showAttackButton:integer)
---@overload fun(dialog:DIALOGRESOURCE, speaker1:CHARACTER, speaker2:CHARACTER, speaker3:CHARACTER, speaker4:CHARACTER, speaker5:CHARACTER, allowLowAttitudeIntercept:integer, allowCrimeIntercept:integer, blockInteractiveIfCombat:integer, showAttackButton:integer)
---@overload fun(dialog:DIALOGRESOURCE, speaker1:CHARACTER, speaker2:CHARACTER, speaker3:CHARACTER, speaker4:CHARACTER, speaker5:CHARACTER, speaker6:CHARACTER, allowLowAttitudeIntercept:integer, allowCrimeIntercept:integer, blockInteractiveIfCombat:integer, showAttackButton:integer)
---@param dialog DIALOGRESOURCE
---@param speaker1 GUIDSTRING
---@param allowLowAttitudeIntercept integer # allow low attitudes to interrupt...?
---@param allowCrimeIntercept integer # allow crime interrogation to interrupt...?
---@param blockInteractiveIfCombat integer # pull out of combat...?
---@param showAttackButton integer # show the attack button in cutscene
function Osi.QRY_StartDialogCustom_Fixed(dialog, speaker1, allowLowAttitudeIntercept, allowCrimeIntercept, blockInteractiveIfCombat, showAttackButton) end