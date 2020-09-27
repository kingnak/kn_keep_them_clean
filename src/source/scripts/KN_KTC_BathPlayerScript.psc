Scriptname KN_KTC_BathPlayerScript extends ReferenceAlias Hidden 

Quest Property KN_KTC_Quest auto

Event OnGetUp(ObjectReference akFurniture)
	(KN_KTC_Quest as KN_KTC_BathQuest).EndBath()
EndEvent
