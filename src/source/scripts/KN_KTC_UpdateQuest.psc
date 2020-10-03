Scriptname KN_KTC_UpdateQuest extends Quest Hidden 

float Property fVersion auto
Quest Property KN_BathQuest auto
FormList Property SBBath_RiftPoolActivator auto
Keyword Property ShowerInnLocationKw auto

Function Maintenance()
	if (fVersion < 1.0)
		fVersion = 1.0
		; Debug.Notification("KN_KTC: Updated to " + fVersion)
	endif
	; Debug.Notification("KN_KTC: Running " + fVersion)
EndFunction

Function ChangedLocation(Location akOldLoc, Location akNewLoc)
	if (akOldLoc.HasKeyword(ShowerInnLocationKw))
		(KN_BathQuest as KN_KTC_BathQuest).FinishBathQuest()
	endif
	if (akNewLoc.HasKeyword(ShowerInnLocationKw))
		_ActivateActivator()
	endif
EndFunction

Function _ActivateActivator()
	ObjectReference rift = Game.FindClosestReferenceOfAnyTypeInListFromRef(SBBath_RiftPoolActivator, Game.GetPlayer(), 500)
	if (rift)
		(rift as AARiftPoolActivator).KN_KTC_Quest = KN_BathQuest
		(KN_BathQuest as KN_KTC_BathQuest).StartBathQuest()
	else
		; Debug.Notification("KN_KTC: No activator found")
	endif
EndFunction
