//entirely neutral or internal status effects go here

/datum/status_effect/sigil_mark //allows the affected target to always trigger sigils while mindless
	id = "sigil_mark"
	duration = -1
	alert_type = null
	var/stat_allowed = DEAD //if owner's stat is below this, will remove itself

/datum/status_effect/sigil_mark/tick()
	if(owner.stat < stat_allowed)
		qdel(src)

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/atom/movable/screen/alert/status_effect/in_love
	name = "In Love"
	desc = "You feel so wonderfully in love!"
	icon_state = "in_love"

/datum/status_effect/in_love
	id = "in_love"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/in_love
	var/mob/living/date

/datum/status_effect/in_love/on_creation(mob/living/new_owner, mob/living/love_interest)
	. = ..()
	if(.)
		date = love_interest
	linked_alert.desc = "You're in love with [date.real_name]! How lovely."

/datum/status_effect/in_love/tick()
	if(date)
		new /obj/effect/temp_visual/love_heart/invisible(get_turf(date.loc), owner)


/datum/status_effect/throat_soothed
	id = "throat_soothed"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/throat_soothed/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/throat_soothed/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/bounty
	id = "bounty"
	status_type = STATUS_EFFECT_UNIQUE
	var/mob/living/rewarded

/datum/status_effect/bounty/on_creation(mob/living/new_owner, mob/living/caster)
	. = ..()
	if(.)
		rewarded = caster

/datum/status_effect/bounty/on_apply()
	to_chat(owner, "[span_boldnotice("You hear something behind you talking...")] [span_notice("You have been marked for death by [rewarded]. If you die, they will be rewarded.")]")
	playsound(owner, 'sound/weapons/shotgunpump.ogg', 75, 0)
	return ..()

/datum/status_effect/bounty/tick()
	if(owner.stat == DEAD)
		rewards()
		qdel(src)

/datum/status_effect/bounty/proc/rewards()
	if(rewarded && rewarded.mind && rewarded.stat != DEAD)
		to_chat(owner, "[span_boldnotice("You hear something behind you talking...")] [span_notice("Bounty claimed.")]")
		playsound(owner, 'sound/weapons/shotgunshot.ogg', 75, 0)
		to_chat(rewarded, span_greentext("You feel a surge of mana flow into you!"))
		for(var/obj/effect/proc_holder/spell/spell in rewarded.mind.spell_list)
			spell.charge_counter = spell.charge_max
			spell.recharging = FALSE
			spell.update_icon()
		rewarded.adjustBruteLoss(-25)
		rewarded.adjustFireLoss(-25)
		rewarded.adjustToxLoss(-25)
		rewarded.adjustOxyLoss(-25)
		rewarded.adjustCloneLoss(-25)

/datum/status_effect/bugged //Lets another mob hear everything you can
	id = "bugged"
	duration = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/mob/living/listening_in

/datum/status_effect/bugged/on_apply(mob/living/new_owner, mob/living/tracker)
	. = ..()
	if (.)
		RegisterSignal(new_owner, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

/datum/status_effect/bugged/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

/datum/status_effect/bugged/proc/handle_hearing(datum/source, list/hearing_args)
	listening_in.show_message(hearing_args[HEARING_MESSAGE])

/datum/status_effect/bugged/on_creation(mob/living/new_owner, mob/living/tracker)
	. = ..()
	if(.)
		listening_in = tracker

/datum/status_effect/tagalong //applied to darkspawns while they accompany someone //yogs start: darkspawn
	id = "tagalong"
	duration = 3000
	tick_interval = 1 //as fast as possible
	alert_type = /atom/movable/screen/alert/status_effect/tagalong
	var/mob/living/shadowing
	var/turf/cached_location //we store this so if the mob is somehow gibbed we aren't put into nullspace

/datum/status_effect/tagalong/on_creation(mob/living/owner, mob/living/tag)
	. = ..()
	if(!.)
		return
	shadowing = tag

/datum/status_effect/tagalong/on_remove()
	if(owner.loc == shadowing)
		owner.forceMove(cached_location ? cached_location : get_turf(owner))
		shadowing.visible_message(span_warning("[owner] breaks away from [shadowing]'s shadow!"), \
		span_userdanger("You feel a sense of freezing cold pass through you!"))
		to_chat(owner, span_velvet("You break away from [shadowing]."))
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, TRUE)
	owner.setDir(SOUTH)

/datum/status_effect/tagalong/process()
	if(!shadowing)
		owner.forceMove(cached_location)
		qdel(src)
		return
	cached_location = get_turf(shadowing)
	if(cached_location.get_lumcount() < DARKSPAWN_DIM_LIGHT)
		owner.forceMove(cached_location)
		shadowing.visible_message(span_warning("[owner] suddenly appears from the dark!"))
		to_chat(owner, span_warning("You are forced out of [shadowing]'s shadow!"))
		owner.Knockdown(30)
		qdel(src)
	var/obj/item/I = owner.get_active_held_item()
	if(I)
		to_chat(owner, span_userdanger("Equipping an item forces you out!"))
		if(istype(I, /obj/item/dark_bead))
			to_chat(owner, span_userdanger("[I] crackles with feedback, briefly disorienting you!"))
			owner.Stun(5) //short delay so they can't click as soon as they're out
		qdel(src)

/atom/movable/screen/alert/status_effect/tagalong
	name = "Tagalong"
	desc = "You are accompanying TARGET_NAME. Use the Tagalong ability to break away at any time."
	icon_state = "shadow_mend"

/atom/movable/screen/alert/status_effect/tagalong/MouseEntered()
	var/datum/status_effect/tagalong/tagalong = attached_effect
	desc = replacetext(desc, "TARGET_NAME", tagalong.shadowing.real_name)
	..()
	desc = initial(desc) //yogs end

// heldup is for the person being aimed at
/datum/status_effect/heldup
	id = "heldup"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /atom/movable/screen/alert/status_effect/heldup

/atom/movable/screen/alert/status_effect/heldup
	name = "Held Up"
	desc = "Making any sudden moves would probably be a bad idea!"
	icon_state = "aimed"

// holdup is for the person aiming
/datum/status_effect/holdup
	id = "holdup"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/holdup

/atom/movable/screen/alert/status_effect/holdup
	name = "Holding Up"
	desc = "You're currently pointing a gun at someone."
	icon_state = "aimed"

/datum/status_effect/notscared
	id = "notscared"
	duration = 600
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null