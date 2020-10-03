Scriptname KN_KTC_BathQuest extends Quest hidden 

Scene Property NpcBathWashScene1 auto
Scene Property NpcBathWashScene2 auto
Spell Property SBBathDispellAllSpell auto
Formlist Property SBBATHAliasesFLST auto
Formlist Property SBBathEffectFLST auto
Formlist Property FurnitureFinderList auto

Idle Property IdleWashHandsCr auto
Idle Property IdleWashHands auto
Idle Property IdleWashArms auto
Idle Property IdleWipeBrows auto
Spell Property WashSpell auto

Formlist Property CurrentBathers auto
Message Property MsgNoMoreBathingSpots auto

int Property maxBathingNpcs = 2 autoReadOnly Hidden

Function StartBath(Actor akActor, bool informNoMoreBathers = false)
	; Only react on bathing NPCs
	if (!SBBATHAliasesFLST.HasForm(akActor))
		return
	endif
	
	; Ensure started
	if (!_StartQuest())
		return
	endif
	
	if (!_EnsureSittingFurnitureLocator())
		return
	endif
	
	int washerIdx = _FindFreeWasherNpcIndex(akActor)
	if (washerIdx < 0)
		if (informNoMoreBathers && washerIdx == -3)
			MsgNoMoreBathingSpots.Show()
		endif
		return
	endif
	
	ReferenceAlias sittingActor = _GetSittingActorRef(washerIdx)
	sittingActor.ForceRefTo(akActor)
	_GetNpcBathScene(washerIdx).Start()
EndFunction

Function EndBath(Actor akActor)
	int idx = _FindExistingWasherNpcIndex(akActor)
	if (idx < 0)
		return
	endif
	
	ReferenceAlias sittingActor = _GetSittingActorRef(idx)
	sittingActor.Clear()
	_GetNpcBathScene(idx).Stop()
EndFunction

Function EndAllBaths()
	int i = 0
	while (i < maxBathingNpcs)
		_GetNpcBathScene(i).Stop()
		_GetSittingActorRef(i).Clear()
		i += 1
	endwhile
EndFunction

Function StartBathQuest()
	_StartQuest()
EndFunction

Function FinishBathQuest()
	EndAllBaths()
	_GetSittingFurnitureLocatorRef().Clear()
	_StopQuest()
EndFunction

bool Function _EnsureSittingFurnitureLocator()
	ReferenceAlias furnitureRef = _GetSittingFurnitureLocatorRef()
	if (!furnitureRef.GetRef())
		ObjectReference furnitureLocation = _FindFurnitureLocator()
		if (furnitureLocation)
			_GetSittingFurnitureLocatorRef().ForceRefTo(furnitureLocation)
		else
			; Debug.Notification("KN_KTC: No furniture location found")
			return false
		endif
	endif
	return true
EndFunction

Function _WashNPCAnimation(Actor akActor, bool turnAround)
	if (!akActor)
		return
	endif
	
	if (turnAround)
		; float angleZ = akActor.GetAngleZ()
		; angleZ += 180
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
	Utility.Wait(1)
	akActor.PlayIdle(IdleWashArms)
	Utility.Wait(5)
	_WashNPC(akActor)
	akActor.RemoveSpell(WashSpell)
	akActor.PlayIdle(IdleWipeBrows)
	Utility.Wait(2)
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

ReferenceAlias Function _GetSittingFurnitureLocatorRef()
	return GetAlias(1) as ReferenceAlias
EndFunction

ReferenceAlias Function _GetSittingActorRef(int idx)
	if (idx < 0 || idx >= maxBathingNpcs)
		return none
	endif
	return GetAlias(2+idx) as ReferenceAlias
EndFunction

Actor Function _GetSittingActor(int idx)
	return _GetSittingActorRef(idx).GetActorRef()
EndFunction

Scene Function _GetNpcBathScene(int idx)
	if (idx == 0)
		return NpcBathWashScene1
	elseif (idx == 1)
		return NpcBathWashScene2
	else
		return none
	endif
EndFunction

ObjectReference Function _FindFurnitureLocator()
	ObjectReference f = Game.FindRandomReferenceOfAnyTypeInListFromRef(FurnitureFinderList, Game.GetPlayer(), 2000)
	return f
EndFunction

int Function _FindExistingWasherNpcIndex(Actor a)
	if (!a)
		return -1
	endif
	
	int i = 0
	while (i < maxBathingNpcs)
		Actor cur = _GetSittingActor(i)
		if (cur == a)
			return i
		endif
		i += 1
	endwhile
	
	return -1
EndFunction

int Function _FindFreeWasherNpcIndex(Actor a)
	if (!a)
		return -1
	endif
	
	int i = 0
	int candidate = -1
	while (i < maxBathingNpcs)
		Actor cur = _GetSittingActor(i)
		if (cur == a)
			; Actor already sitting, no valid index
			return -2
		elseif (cur == none && candidate < 0)
			; Empty ref, remember it
			candidate = i
		endif
		i += 1
	endwhile
	
	if (candidate < 0)
		; No more bathing spots
		return -3
	endif
	
	return candidate
EndFunction

Function _FillCurrentBathers()
	CurrentBathers.Revert()
	int i = 0
	while (i < SBBATHAliasesFLST.GetSize())
		Form f = (SBBATHAliasesFLST.GetAt(i) as ObjectReference).GetBaseObject()
		CurrentBathers.AddForm(f)
		; Debug.Notification("Added " + f.GetFormID() + ": " + f.GetName())
		i += 1
	endwhile
EndFunction

bool Function _StartQuest()
	if (!self.IsStopped())
		return true
	endif
	
	_CleanUp()
	_FillCurrentBathers()
	
	; Debug.Notification("KN_KTC: Starting Quest")
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
	
	; Debug.Notification("KN_KTC: Stopping Quest")
	self.Stop()
	int i = 0
	while (!self.IsStopped() && i < 50)
		Utility.Wait(0.1)
		i += 1
	endwhile
	
	_CleanUp()
EndFunction

Function _CleanUp()
	int i = 0
	while (i < maxBathingNpcs)
		_GetNpcBathScene(i).Stop()
		_GetSittingActorRef(i).Clear()
		i += 1
	endwhile
	_GetSittingFurnitureLocatorRef().Clear()
	CurrentBathers.Revert()
EndFunction
