Scriptname KN_KTC_BathQuest extends Quest hidden 

Scene Property SittingScene auto
Spell Property SBBathDispellAllSpell auto
Formlist Property SBBATHAliasesFLST auto
Formlist Property SBBathEffectFLST auto
Formlist Property FurnitureFinderList auto

Function StartBath(Actor akActor)
	; Only react on bathing NPCs
	;Debug.Notification("KN_KTC: Starting Bath")
	if (!SBBATHAliasesFLST.HasForm(akActor))
		return
	endif
	
	; Ensure started, and don't run twice
	if (!_StartQuest())
		return
	endif
	
	ReferenceAlias sittingActor = _GetSittingActor()
	if (!sittingActor.GetActorRef())
		sittingActor.ForceRefTo(akActor)
		
		ObjectReference furnitureLocation = _FindFurniture()
		if (furnitureLocation)
			_GetSittingFurniture().ForceRefTo(furnitureLocation)
			SittingScene.Start()
			GotoState("GoingToSit")
			RegisterForSingleUpdate(1)
		else
			;Debug.Notification("KN_KTC: No furniture location found")
		endif
	endif
EndFunction

Function EndBath(Actor akActor = none)
	;Debug.Notification("KN_KTC: Ending Bath")
	ReferenceAlias sittingActor = _GetSittingActor()
	if (sittingActor.GetActorRef()) 
		if (akActor != none)
			if (akActor != sittingActor.GetActorRef())
				return
			endif
		endif
	endif
	sittingActor.Clear()
	SittingScene.Stop()
	UnregisterForUpdate()
	_StopQuest()
EndFunction

Auto State GoingToSit
Event OnUpdate()
	Actor myActor = _GetSittingActor().GetActorRef()
	if (!myActor) 
		return
	endif
	
	if (myActor.GetSitState() > 0)
		GotoState("Washing")
		RegisterForSingleUpdate(5)
	else
		RegisterForSingleUpdate(1)
	endif
EndEvent
EndState

State Washing
Event OnUpdate()
	Actor myActor = _GetSittingActor().GetActorRef()
	if (!myActor) 
		return
	endif
	
	int i = 0
	int ct = SBBathEffectFLST.GetSize()
	while ( i < ct )
		Spell s = SBBathEffectFLST.GetAt(i) As Spell
		myActor.RemoveSpell(s)
		i += 1
	endwhile
	
	myActor.AddSpell(SBBathDispellAllSpell, False)
EndEvent
EndState

ReferenceAlias Function _GetSittingActor()
	return GetAlias(1) as ReferenceAlias
EndFunction

ReferenceAlias Function _GetSittingFurniture()
	return GetAlias(2) as ReferenceAlias
EndFunction

ObjectReference Function _FindFurniture()
	ObjectReference f = Game.FindClosestReferenceOfAnyTypeInListFromRef(FurnitureFinderList, Game.GetPlayer(), 2000)
	;Debug.Notification("KN_KTC: Found furniture around " + f)
	return f
EndFunction

bool Function _StartQuest()
	if (!self.IsStopped())
		return false
	endif
	;Debug.Notification("KN_KTC: Starting Quest")
	self.Start()
	int i = 0
	while (self.IsStopped() && i < 50)
		Utility.Wait(0.1)
		i += 1
	endwhile
	return !self.IsStopped()
EndFunction

Function _StopQuest()
	if (self.IsStopped())
		return
	endif
	;Debug.Notification("KN_KTC: Stopping Quest")
	self.Stop()
	int i = 0
	while (!self.IsStopped() && i < 50)
		Utility.Wait(0.1)
		i += 1
	endwhile
EndFunction

