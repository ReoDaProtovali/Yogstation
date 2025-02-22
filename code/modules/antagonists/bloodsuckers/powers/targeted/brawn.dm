/datum/action/bloodsucker/targeted/brawn
	name = "Brawn"
	desc = "Snap restraints, break lockers and doors, or deal terrible damage with your bare hands."
	button_icon_state = "power_strength"
	power_explanation = "<b>Brawn</b>:\n\
		Click any person to bash into them, break restraints you have or knocking a grabber down. Only one of these can be done per use.\n\
		Punching a Cyborg will heavily EMP them in addition to deal damage.\n\
		At level 3, you get the ability to break closets open, additionally can both break restraints AND knock a grabber down in the same use.\n\
		At level 4, you get the ability to bash airlocks open, as long as they aren't bolted.\n\
		Higher levels will increase the damage and knockdown when punching someone."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 8
	cooldown = 9 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "Select a target."

/datum/action/bloodsucker/targeted/brawn/CheckCanUse(mob/living/carbon/user)
	. = ..()
	if(!.) // Default checks
		return FALSE

	// Did we break out of our handcuffs?
	if(CheckBreakRestraints())
		PowerActivatedSuccessfully()
		return FALSE
	// Did we knock a grabber down? We can only do this while not also breaking restraints if strong enough.
	if(level_current >= 3 && CheckEscapePuller())
		PowerActivatedSuccessfully()
		return FALSE
	// Did neither, now we can PUNCH.
	return TRUE

// Look at 'biodegrade.dm' for reference
/datum/action/bloodsucker/targeted/brawn/proc/CheckBreakRestraints()
	var/mob/living/carbon/human/user = owner
	///Only one form of shackles removed per use
	var/used = FALSE

	// Breaks out of lockers
	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = user.loc
		if(!istype(closet))
			return FALSE
		closet.visible_message(
			span_warning("[closet] tears apart as [user] bashes it open from within!"),
			span_warning("[closet] tears apart as you bash it open from within!"),
		)
		to_chat(user, span_warning("We bash [closet] wide open!"))
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, closet), 1)
		used = TRUE

	// Remove both Handcuffs & Legcuffs
	var/obj/cuffs = user.get_item_by_slot(SLOT_HANDCUFFED)
	var/obj/legcuffs = user.get_item_by_slot(SLOT_LEGCUFFED)
	if(!used && (istype(cuffs) || istype(legcuffs)))
		user.visible_message(
			span_warning("[user] discards their restraints like it's nothing!"),
			span_warning("We break through our restraints!"),
		)
		user.clear_cuffs(cuffs, TRUE)
		user.clear_cuffs(legcuffs, TRUE)
		used = TRUE

	// Remove Straightjackets
	if(user.wear_suit?.breakouttime && !used)
		var/obj/item/clothing/suit/straightjacket = user.get_item_by_slot(SLOT_WEAR_SUIT)
		if(!istype(straightjacket))
			return
		user.visible_message(
			span_warning("[user] rips straight through [user.p_their()] [straightjacket.name]!"),
			span_warning("We tear through our [straightjacket.name]!"),
		)
		if(straightjacket && user.wear_suit == straightjacket)
			new /obj/item/stack/sheet/cloth(user.loc, 3)
			qdel(straightjacket)
		used = TRUE

	// Did we end up using our ability? If so, play the sound effect and return TRUE
	if(used)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, TRUE, -1)
	return used

// This is its own proc because its done twice, to repeat code copypaste.
/datum/action/bloodsucker/targeted/brawn/proc/break_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	if(closet)
		closet.welded = FALSE
		closet.locked = FALSE
		closet.broken = TRUE
		closet.open()

/datum/action/bloodsucker/targeted/brawn/proc/CheckEscapePuller()
	if(!owner.pulledby) // || owner.pulledby.grab_state <= GRAB_PASSIVE)
		return FALSE
	var/mob/pulled_mob = owner.pulledby
	var/pull_power = pulled_mob.grab_state
	playsound(get_turf(pulled_mob), 'sound/effects/woodhit.ogg', 75, TRUE, -1)
	// Knock Down (if Living)
	if(isliving(pulled_mob))
		var/mob/living/hit_target = pulled_mob
		hit_target.Knockdown(pull_power * 10 + 20)
	// Knock Back (before Knockdown, which probably cancels pull)
	var/send_dir = get_dir(owner, pulled_mob)
	var/turf/turf_thrown_at = get_ranged_target_turf(pulled_mob, send_dir, pull_power)
	owner.newtonian_move(send_dir) // Bounce back in 0 G
	pulled_mob.throw_at(turf_thrown_at, pull_power, TRUE, owner, FALSE) // Throw distance based on grab state! Harder grabs punished more aggressively.
	// /proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	log_combat(owner, pulled_mob, "used Brawn power")
	owner.visible_message(
		span_warning("[owner] tears free of [pulled_mob]'s grasp!"),
		span_warning("You shrug off [pulled_mob]'s grasp!"),
	)
	owner.pulledby = null // It's already done, but JUST IN CASE.
	return TRUE

/datum/action/bloodsucker/targeted/brawn/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner
	// Target Type: Mob
	if(isliving(target_atom))
		var/mob/living/target = target_atom
		var/mob/living/carbon/carbonuser = user
		var/hitStrength = carbonuser.dna.species.punchdamagehigh * 1.25 + 2
		// Knockdown!
		var/powerlevel = min(5, 1 + level_current)
		if(rand(5 + powerlevel) >= 5)
			target.visible_message(
				span_danger("[user] lands a vicious punch, sending [target] away!"), \
				span_userdanger("[user] has landed a horrifying punch on you, sending you flying!"),
			)
			target.Knockdown(min(5 SECONDS, rand(1 SECONDS, 1 SECONDS * powerlevel)))
		// Attack!
		to_chat(owner, span_warning("You punch [target]!"))
		playsound(get_turf(target), 'sound/weapons/punch4.ogg', 60, TRUE, -1)
		user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(target.zone_selected))
		var/blocked = target.run_armor_check(affecting, MELEE, armour_penetration = 20)	//20 AP, will ignore light armor but not heavy stuff
		target.apply_damage(hitStrength, BRUTE, affecting, blocked)
		// Knockback
		var/send_dir = get_dir(owner, target)
		var/turf/turf_thrown_at = get_ranged_target_turf(target, send_dir, powerlevel)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		target.throw_at(turf_thrown_at, powerlevel, TRUE, owner) //new /datum/forced_movement(target, get_ranged_target_turf(target, send_dir, (hitStrength / 4)), 1, FALSE)
		// Target Type: Cyborg (Also gets the effects above)
		if(issilicon(target))
			target.emp_act(EMP_HEAVY)
	// Target Type: Locker
	else if(istype(target_atom, /obj/structure/closet) && level_current >= 3)
		var/obj/structure/closet/target_closet = target_atom
		to_chat(user, span_warning("You prepare to bash [target_closet] open..."))
		if(!do_mob(user, target_closet, 2.5 SECONDS))
			return FALSE
		target_closet.visible_message(span_danger("[target_closet] breaks open as [user] bashes it!"))
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, target_closet), 1)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, TRUE, -1)
	// Target Type: Door
	else if(istype(target_atom, /obj/machinery/door) && level_current >= 4)
		var/obj/machinery/door/target_airlock = target_atom
		playsound(get_turf(user), 'sound/machines/airlock_alien_prying.ogg', 40, TRUE, -1)
		to_chat(owner, span_warning("You prepare to tear open [target_airlock]..."))
		if(!do_mob(user, target_airlock, 2.5 SECONDS))
			return FALSE
		if(target_airlock.Adjacent(user))
			target_airlock.visible_message(span_danger("[target_airlock] breaks open as [user] bashes it!"))
			user.Stun(10)
			user.do_attack_animation(target_airlock, ATTACK_EFFECT_SMASH)
			playsound(get_turf(target_airlock), 'sound/effects/bang.ogg', 30, TRUE, -1)
			target_airlock.open(2) // open(2) is like a crowbar or jaws of life.

/datum/action/bloodsucker/targeted/brawn/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom) || istype(target_atom, /obj/machinery/door) || istype(target_atom, /obj/structure/closet)

/datum/action/bloodsucker/targeted/brawn/CheckCanTarget(atom/target_atom)
	// DEFAULT CHECKS (Distance)
	. = ..()
	if(!.) // Disable range notice for Brawn.
		return FALSE
	// Must outside Closet to target anyone!
	if(!isturf(owner.loc))
		return FALSE
	// Target Type: Living
	if(isliving(target_atom))
		return TRUE
	// Target Type: Door
	else if(istype(target_atom, /obj/machinery/door))
		if(level_current < 4)
			to_chat(owner, span_warning("You need [4 - level_current] more levels to be able to break open the [target_atom]!"))
			return FALSE
		return TRUE
	// Target Type: Locker
	else if(istype(target_atom, /obj/structure/closet))
		if(level_current < 3)
			to_chat(owner, span_warning("You need [3 - level_current] more levels to be able to break open the [target_atom]!"))
			return FALSE
		return TRUE
	return FALSE

/datum/action/bloodsucker/targeted/brawn/shadow
	name = "Obliterate"
	button_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	background_icon_state_on = "lasombra_power_on"
	background_icon_state_off = "lasombra_power_off"
	icon_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	button_icon_state = "power_obliterate"
	additional_text = "Additionally afflicts the target with a shadow curse while in darkness and disables any lights they may possess."
	purchase_flags = LASOMBRA_CAN_BUY

/datum/action/bloodsucker/targeted/brawn/shadow/FireTargetedPower(atom/target_atom)
	var/mob/living/carbon/human/H = target_atom
	H.apply_status_effect(STATUS_EFFECT_SHADOWAFFLICTED)
	var/turf/T = get_turf(H)
	for(var/datum/light_source/LS in T.get_affecting_lights())
		var/atom/LO = LS.source_atom
		if(isitem(LO))
			var/obj/item/I = LO
			if(istype(I, /obj/item/clothing/head/helmet/space/hardsuit))
				var/obj/item/clothing/head/helmet/space/hardsuit/HA = I
				HA.set_light_on(FALSE)
			if(istype(I, /obj/item/clothing/head/helmet/space/plasmaman))
				var/obj/item/clothing/head/helmet/space/plasmaman/PA = I
				PA.set_light_on(FALSE)
			if(istype(I, /obj/item/flashlight))
				var/obj/item/flashlight/F = I
				F.set_light_on(FALSE)
		if(istype(LO, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/borg = LO
			if(!borg.lamp_cooldown)
				borg.smash_headlamp()
	. = ..()
