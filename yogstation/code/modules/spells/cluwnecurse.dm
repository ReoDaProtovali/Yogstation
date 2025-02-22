/obj/effect/proc_holder/spell/targeted/cluwnecurse
	name = "Curse of the Cluwne"
	desc = "This spell dooms the fate of any unlucky soul to the live of a pitiful cluwne, a terrible creature that is hunted for fun."
	school = "transmutation"
	charge_max	= 600
	charge_counter = 0
	clothes_req = 1
	stat_allowed = 0
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = SPELL_INVOCATION_SAY
	range = 3
	cooldown_min = 75
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human)
	action_icon = 'yogstation/icons/mob/actions.dmi'
	action_icon_state = "cluwne"

/obj/effect/proc_holder/spell/targeted/cluwnecurse/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, span_notice("No target found in range."))
		return
	var/mob/living/carbon/target = targets[1]
	if(!(target.type in compatible_mobs))
		to_chat(user, span_notice("You are unable to curse [target]!"))
		return
	if(!(target in oview(range)))
		to_chat(user, span_notice("They are too far away!"))
		return
	if(target.anti_magic_check())
		to_chat(user, span_notice("They didn't laugh!"))
		return
	var/mob/living/carbon/human/H = target
	H.cluwneify()

/datum/spellbook_entry/cluwnecurse
	name = "Cluwne Curse"
	spell_type = /obj/effect/proc_holder/spell/targeted/cluwnecurse

/datum/action/spell_action/New(Target)
	..()
	var/obj/effect/proc_holder/spell/S = Target
	icon_icon = S.action_icon
