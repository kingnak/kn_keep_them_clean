Scriptname KN_KTC_BathPlayerScript extends ReferenceAlias Hidden 

Quest Property BathQuest auto
GlobalVariable Property EndBathOnStandup auto

Event OnGetUp(ObjectReference akFurniture)
	if (EndBathOnStandup.GetValue() == 1)
		(BathQuest as KN_KTC_BathQuest).EndAllBaths()
	endif
EndEvent
