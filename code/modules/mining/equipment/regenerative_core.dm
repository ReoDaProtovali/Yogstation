/*********************Hivelord stabilizer****************/
/obj/item/hivelordstabilizer
	name = "stabilizing serum"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject certain types of monster organs with this stabilizer to preserve their healing powers indefinitely."
	w_class = WEIGHT_CLASS_TINY

/obj/item/hivelordstabilizer/afterattack(obj/item/organ/M, mob/user)
	. = ..()
	var/obj/item/organ/regenerative_core/C = M
	if(!istype(C, /obj/item/organ/regenerative_core))
		to_chat(user, span_warning("The stabilizer only works on certain types of monster organs, generally regenerative in nature."))
		return ..()

	C.preserved()
	to_chat(user, span_notice("You inject the [M] with the stabilizer. It will no longer go inert."))
	qdel(src)

/************************Hivelord core*******************/
/obj/item/organ/regenerative_core
	name = "regenerative core"
	desc = "All that remains of a hivelord. It can be used to heal quickly, but it will rapidly decay into uselessness. Radiation found in active space installments will slow its healing effects."
	icon_state = "roro core 2"
	visual = FALSE
	item_flags = NOBLUDGEON
	slot = "hivecore"
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0

/obj/item/organ/regenerative_core/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(inert_check)), 2400)

/obj/item/organ/regenerative_core/proc/inert_check()
	if(!preserved)
		go_inert()

/obj/item/organ/regenerative_core/proc/preserved(implanted = 0)
	inert = FALSE
	preserved = TRUE
	update_icon()
	name = "preserved regenerative core"
	desc = "All that remains of a hivelord. It is preserved, allowing you to use it to heal completely without danger of decay."
	if(implanted)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "implanted"))
	else
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "stabilizer"))

/obj/item/organ/regenerative_core/proc/go_inert()
	inert = TRUE
	name = "decayed regenerative core"
	desc = "All that remains of a hivelord. It has decayed, and is completely useless."
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "inert"))
	update_icon()

/obj/item/organ/regenerative_core/ui_action_click()
	if(inert)
		to_chat(owner, span_notice("[src] breaks down as it tries to activate."))
	else
		owner.revive(full_heal = 1)
	qdel(src)

/obj/item/organ/regenerative_core/on_life()
	..()
	if(owner.health <= owner.crit_threshold)
		ui_action_click()
		
/obj/item/organ/regenerative_core/attack_self(mob/user)
	afterattack(user, user, TRUE)
	
/obj/item/organ/regenerative_core/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/turf/user_turf = get_turf(user)
		if(inert)
			to_chat(user, span_notice("[src] has decayed and can no longer be used to heal."))
			return
		else
			if(H.stat == DEAD)
				to_chat(user, span_notice("[src] are useless on the dead."))
				return
			if(H != user)
			
				if(!is_station_level(user_turf.z) || is_reserved_level(user_turf.z))
					H.visible_message(span_notice("[user] crushes [src] against [H]'s body, causing black tendrils to encover and reinforce [H.p_them()]!"))
				else
					H.visible_message(span_notice("[user] holds [src] against [H]'s body, coaxing the regenerating tendrils from [src]..."))
					balloon_alert(user, "Applying core...")
					if(!do_mob(user, H, 2 SECONDS)) //come on teamwork bonus?
						to_chat(user, span_warning("You are interrupted, causing [src]'s tendrils to retreat back into its form."))
						return
					balloon_alert(user, "Core applied!")
					H.visible_message(span_notice("[src] explodes into a flurry of tendrils, rapidly covering and reinforcing [H]'s body."))
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
			else
				if(!is_station_level(user_turf.z) || is_reserved_level(user_turf.z))
					to_chat(user, span_notice("You crush [src] within your hand. Disgusting tendrils spread across your body, hold you together and allow you to keep moving, but for how long?"))
				else
					to_chat(user, span_notice("You hold [src] against your body, coaxing the regenerating tendrils from [src]..."))
					balloon_alert(user, "Applying core...")
					if(!do_after(user, 4 SECONDS, src))
						to_chat(user, span_warning("You are interrupted, causing [src]'s tendrils to retreat back into its form."))
						return
					balloon_alert(user, "Core applied!")
					to_chat(user, span_notice("[src] explodes into a flurry of tendrils, rapidly spreading across your body. They will hold you together and allow you to keep moving, but for how long?"))
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
			H.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "core", /datum/mood_event/healsbadman) //Now THIS is a miner buff (fixed - nerf)
			qdel(src)

/obj/item/organ/regenerative_core/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(!preserved && !inert)
		preserved(TRUE)
		owner.visible_message(span_notice("[src] stabilizes as it's inserted."))

/obj/item/organ/regenerative_core/Remove(mob/living/carbon/M, special = 0)
	if(!inert && !special)
		owner.visible_message(span_notice("[src] rapidly decays as it's removed."))
		go_inert()
	return ..()

/obj/item/organ/regenerative_core/prepare_eat()
	return null

/*************************Legion core********************/
/obj/item/organ/regenerative_core/legion
	desc = "A strange rock that crackles with power. It can be used to heal quickly, but it will rapidly decay into uselessness. Radiation found in active space installments will slow its healing effects."
	icon_state = "legion_soul"

/obj/item/organ/regenerative_core/legion/Initialize()
	. = ..()
	update_icon()

/obj/item/organ/regenerative_core/update_icon()
	icon_state = inert ? "legion_soul_inert" : "legion_soul"
	cut_overlays()
	if(!inert && !preserved)
		add_overlay("legion_soul_crackle")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/regenerative_core/legion/go_inert()
	..()
	desc = "[src] has become inert. It has decayed, and is completely useless."

/obj/item/organ/regenerative_core/legion/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It is preserved, allowing you to use it to heal completely without danger of decay."
