Scriptname AARiftPoolActivator extends ObjectReference   

Spell Property AARiftPoolSpell auto
Quest Property KN_KTC_Quest auto

Event OnTriggerEnter(ObjectReference triggerRef)  
	Actor akActionRef = triggerRef as Actor 
	if (akActionRef != Game.GetPlayer() && !akActionRef.isincombat())
		AARiftPoolSpell.Cast(akActionRef,akActionRef) 
		; Give KN_KTC chance to update quest
		if (!KN_KTC_Quest)
			Utility.Wait(1)
		endif
		if (KN_KTC_Quest)
			(KN_KTC_Quest as KN_KTC_BathQuest).StartBath(akActionRef)
		endif
	endif 
EndEvent 

Event OnTriggerLeave(ObjectReference triggerRef) 
	Actor akActionRef = triggerRef as Actor 
	if (akActionRef != Game.GetPlayer())  
		akActionRef.DispelSpell(AARiftPoolSpell)
		if (KN_KTC_Quest)
			(KN_KTC_Quest as KN_KTC_BathQuest).EndBath(akActionRef)
		endif
	endif 
EndEvent
