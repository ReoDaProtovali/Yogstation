/obj/effect/proc_holder/spell/targeted/area_teleport
	name = "Area teleport"
	desc = "This spell teleports you to a type of area of your selection."
	nonabstract_req = TRUE

	var/randomise_selection = FALSE //if it lets the usr choose the teleport loc or picks it from the list
	var/invocation_area = TRUE //if the invocation appends the selected area
	var/sound1 = 'sound/weapons/zapbang.ogg'
	var/sound2 = 'sound/weapons/zapbang.ogg'

	var/say_destination = TRUE

/obj/effect/proc_holder/spell/targeted/area_teleport/perform(list/targets, recharge = 1,mob/living/user = usr)
	var/thearea = before_cast(targets)
	if(!thearea || !cast_check(1))
		revert_cast()
		return
	invocation(thearea,user)
	if(charge_type == SPELL_CHARGE_TYPE_RECHARGE && recharge)
		INVOKE_ASYNC(src, PROC_REF(start_recharge))
	cast(targets,thearea,user)
	after_cast(targets)

/obj/effect/proc_holder/spell/targeted/area_teleport/before_cast(list/targets)
	var/A = null

	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) as null|anything in GLOB.teleportlocs
	else
		A = pick(GLOB.teleportlocs)
	if(!A)
		return
	var/area/thearea = GLOB.teleportlocs[A]

	return thearea

/obj/effect/proc_holder/spell/targeted/area_teleport/cast(list/targets,area/thearea,mob/user = usr)
	playsound(get_turf(user), sound1, 50,1)
	for(var/mob/living/target in targets)
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			if(!T.density)
				var/clear = TRUE
				for(var/obj/O in T)
					if(O.density)
						clear = FALSE
						break
				if(clear)
					L+=T

		if(!L.len)
			to_chat(usr, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
			return

		if(target && target.buckled)
			target.buckled.unbuckle_mob(target, force=1)

		var/list/tempL = L
		var/attempt = null
		var/success = FALSE
		while(tempL.len)
			attempt = pick(tempL)
			do_teleport(target, attempt, channel = TELEPORT_CHANNEL_MAGIC)
			if(get_turf(target) == attempt)
				success = TRUE
				break
			else
				tempL.Remove(attempt)

		if(!success)
			do_teleport(target, L, forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
			playsound(get_turf(user), sound2, 50,1)

/obj/effect/proc_holder/spell/targeted/area_teleport/invocation(area/chosenarea = null,mob/living/user = usr)
	if(say_destination && chosenarea)
		invocation = "[initial(invocation)] [uppertext(chosenarea.name)]"
	else
		invocation = initial(invocation)
	..()
