Scriptname KN_KTC_MaintenanceScript extends ReferenceAlias Hidden

KN_KTC_UpdateQuest Property QuestScript auto

Event OnPlayerLoadGame()
	QuestScript.Maintenance()
	;QuestScript.Init()
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	QuestScript.ChangedLocation(akNewLoc)
EndEvent
