Scriptname AARiftPoolActivator extends ObjectReference   

Spell Property AARiftPoolSpell auto
Quest Property KN_KTC_Quest auto

Event OnTriggerEnter(ObjectReference triggerRef)  
	Actor akActionRef = triggerRef as Actor 
	if (akActionRef != Game.GetPlayer() && !akActionRef.isincombat())
		AARiftPoolSpell.Cast(akActionRef,akActionRef) 
		
		int i = 0
		; Give KN_KTC chance to update quest
		while (!KN_KTC_Quest && i < 50)
			Utility.Wait(0.1)
			i += 1
		endwhile
		if (KN_KTC_Quest)
			(KN_KTC_Quest as KN_KTC_BathQuest).StartBath(akActionRef)
		else
			; Debug.Notification("No quest, abort")
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
