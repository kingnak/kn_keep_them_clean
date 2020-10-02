Scriptname KN_KTC_BathQuest extends Quest hidden 

Scene Property NpcBathWashScene auto
Spell Property SBBathDispellAllSpell auto
Formlist Property SBBATHAliasesFLST auto
Formlist Property SBBathEffectFLST auto
Formlist Property FurnitureFinderList auto

Idle Property IdleWashHandsCr auto
Idle Property IdleWashHands auto
Idle Property IdleWipeBrows auto
Spell Property WashSpell auto

Function StartBath(Actor akActor)
	; Only react on bathing NPCs
	if (!SBBATHAliasesFLST.HasForm(akActor))
		return
	endif
	
	; Debug.Notification("KN_KTC: Starting Bath")
	; Ensure started, and don't run twice
	if (!_StartQuest())
		return
	endif
	
	ReferenceAlias sittingActor = _GetSittingActorRef()
	if (!sittingActor.GetActorRef())
		sittingActor.ForceRefTo(akActor)
		
		ObjectReference furnitureLocation = _FindFurnitureLocation()
		if (furnitureLocation)
			_GetSittingFurnitureRef().ForceRefTo(furnitureLocation)
			NpcBathWashScene.Start()
		else
			; Debug.Notification("KN_KTC: No furniture location found")
		endif
	endif
EndFunction

Function EndBath(Actor akActor = none)
	;Debug.Notification("KN_KTC: Ending Bath")
	ReferenceAlias sittingActor = _GetSittingActorRef()
	if (sittingActor.GetActorRef()) 
		if (akActor != none)
			if (akActor != sittingActor.GetActorRef())
				return
			endif
		endif
	endif
	sittingActor.Clear()
	_GetSittingFurnitureRef().Clear()
	NpcBathWashScene.Stop()
	_StopQuest()
EndFunction

Function _WashNPCAnimation(Actor akActor, bool turnAround)
	if (!akActor)
		return
	endif
	
	if (turnAround)
		float angleZ = akActor.GetAngleZ()
		angleZ += 180
		; akActor.TranslateTo(akActor.GetPositionX(), akActor.getPositionY(), akActor.GetPositionZ(), akActor.GetAngleX(), akActor.GetAngleY(), angleZ, 0.0, 150)
		akActor.SetLookAt(Game.GetPlayer(), true)
		Utility.Wait(1.5)
		akActor.ClearLookAt()
	else
		Utility.Wait(1.5)
	endif
	
	akActor.AddSpell(WashSpell, false)
	WashSpell.Cast(akActor, akActor)
	Utility.Wait(3)
	akActor.PlayIdle(IdleWashHandsCr)
	Utility.Wait(5)
	akActor.PlayIdle(IdleWashHands)
	_WashNPC(akActor)
	Utility.Wait(3)
	akActor.PlayIdle(IdleWipeBrows)
	akActor.RemoveSpell(WashSpell)
	Utility.Wait(1.5)
EndFunction

Function _WashNPC(Actor akActor)
	if (!akActor) 
		return
	endif
	
	int i = 0
	int ct = SBBathEffectFLST.GetSize()
	while ( i < ct )
		Spell s = SBBathEffectFLST.GetAt(i) As Spell
		akActor.RemoveSpell(s)
		i += 1
	endwhile
	
	akActor.AddSpell(SBBathDispellAllSpell, False)
EndFunction

ReferenceAlias Function _GetSittingActorRef()
	return GetAlias(1) as ReferenceAlias
EndFunction

ReferenceAlias Function _GetSittingFurnitureRef()
	return GetAlias(2) as ReferenceAlias
EndFunction

Actor Function _GetSittingActor()
	return _GetSittingActorRef().GetActorRef()
EndFunction

ObjectReference Function _GetSittingFurniture()
	return _GetSittingFurnitureRef().GetRef() as ObjectReference
EndFunction

ObjectReference Function _FindFurnitureLocation()
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
