/* Level 1: Speed to location
 * Level 2: Dodge Bullets
 * Level 3: Stun People Passed
 */

/datum/action/bloodsucker/targeted/haste
	name = "Immortal Haste"
	desc = "Dash somewhere with supernatural speed. Those nearby may be knocked away, stunned, or left empty-handed."
	button_icon_state = "power_speed"
	power_explanation = "<b>Immortal Haste</b>:\n\
		Click anywhere to immediately dash towards that location.\n\
		The Power will not work if you are lying down, in no gravity, or are aggressively grabbed.\n\
		Anyone in your way during your Haste will be knocked down and Payalyzed, moreso if they are using Flow.\n\
		Higher levels will increase the knockdown dealt to enemies."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 6
	cooldown = 12 SECONDS
	target_range = 15
	power_activates_immediately = TRUE
	var/list/hit //current hit, set while power is in use as we can't pass the list as an extra calling argument in registersignal.
	/// If set, uses this speed in deciseconds instead of world.tick_lag
	var/speed_override

/datum/action/bloodsucker/targeted/haste/CheckCanUse(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE
	// Being Grabbed
	if(user.pulledby && user.pulledby.grab_state >= GRAB_AGGRESSIVE)
		to_chat(user, span_warning("You're being grabbed!"))
		return FALSE
	if(!user.has_gravity(user.loc)) //We dont want people to be able to use this to fly around in space
		to_chat(user, span_warning("You cannot dash while floating!"))
		return FALSE
	if(!(user.mobility_flags & MOBILITY_STAND))
		to_chat(user, span_warning("You must be standing to tackle!"))
		return FALSE
	return TRUE

/// Anything will do, if it's not me or my square
/datum/action/bloodsucker/targeted/haste/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return target_atom.loc != owner.loc

/// This is a non-async proc to make sure the power is "locked" until this finishes.
/datum/action/bloodsucker/targeted/haste/FireTargetedPower(atom/target_atom)
	. = ..()
	hit = list()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	var/mob/living/user = owner
	var/turf/targeted_turf = isturf(target_atom) ? target_atom : get_turf(target_atom)
	// Pulled? Not anymore.
	user.pulledby?.stop_pulling()
	// Go to target turf
	// DO NOT USE WALK TO.
	to_chat(owner, span_notice("You dash into the air!"))
	playsound(get_turf(owner), 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	var/safety = get_dist(user, targeted_turf) * 3 + 1
	var/consequetive_failures = 0
	var/speed = isnull(speed_override)? world.tick_lag : speed_override
	while(--safety && (get_turf(user) != targeted_turf))
		var/success = step_towards(user, targeted_turf) //This does not try to go around obstacles.
		if(!success)
			success = step_to(user, targeted_turf) //this does
		if(!success)
			if(++consequetive_failures >= 3) //if 3 steps don't work
				break //just stop
		else
			consequetive_failures = 0
		if(user.resting)
			user.setDir(turn(user.dir, 90)) //down? spin2win?
		if(user.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE)) //actually down? stop.
			break
		if(success) //don't sleep if we failed to move.
			sleep(speed)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	hit = null

/datum/action/bloodsucker/targeted/haste/proc/on_move()
	for(var/mob/living/all_targets in dview(1, get_turf(owner)))
		if(!hit[all_targets] && (all_targets != owner))
			hit[all_targets] = TRUE
			playsound(all_targets, "sound/weapons/punch[rand(1,4)].ogg", 15, 1, -1)
			all_targets.Knockdown(10 + level_current * 5)
			all_targets.Paralyze(0.1)
			all_targets.spin(10, 1)
			if(IS_MONSTERHUNTER(all_targets) && HAS_TRAIT(all_targets, TRAIT_STUNIMMUNE))
				to_chat(all_targets, "Knocked down!")
				for(var/datum/action/bloodsucker/power in all_targets.actions)
					if(power.active)
						power.DeactivatePower()
				all_targets.Jitter(20)
				all_targets.confused = max(8, all_targets.confused)
				all_targets.stuttering = max(8, all_targets.stuttering)
				all_targets.Knockdown(10 + level_current * 5) // Re-knock them down, the first one didn't work due to stunimmunity

/datum/action/bloodsucker/targeted/haste/shadow
	name = "Blow"
	button_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	background_icon_state_on = "lasombra_power_on"
	background_icon_state_off = "lasombra_power_off"
	icon_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	button_icon_state = "power_bomb"
	additional_text = "Additionally disables lightframes in range and confuses nearby mortals."
	purchase_flags = LASOMBRA_CAN_BUY

/datum/action/bloodsucker/targeted/haste/shadow/on_move()
	. = ..()
	var/mob/living/carbon/human/user = owner
	for(var/obj/machinery/light/L in range(5, user))
		L.on = FALSE
		L.update(0)
		L.set_light(0)
	for(var/mob/target in range(5, user))
		if(target == user)
			continue
		if(IS_BLOODSUCKER(target) || IS_VASSAL(target))
			continue
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			to_chat(M, span_danger("<b>As a figure passes by, you feel your head spike up!</b>"))
			M.confused += 4
			M.adjustEarDamage(0, 15)