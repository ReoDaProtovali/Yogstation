/datum/component/stationloving
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/inform_admins = FALSE
	var/disallow_soul_imbue = TRUE
	var/allow_death = FALSE

/datum/component/stationloving/Initialize(inform_admins = FALSE, allow_death = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignals(parent, list(COMSIG_MOVABLE_Z_CHANGED), PROC_REF(check_in_bounds))
	RegisterSignals(parent, list(COMSIG_MOVABLE_SECLUDED_LOCATION), PROC_REF(relocate))
	RegisterSignals(parent, list(COMSIG_PARENT_PREQDELETED), PROC_REF(check_deletion))
	RegisterSignals(parent, list(COMSIG_ITEM_IMBUE_SOUL), PROC_REF(check_soul_imbue))
	src.inform_admins = inform_admins
	src.allow_death = allow_death
	check_in_bounds() // Just in case something is being created outside of station/centcom

/datum/component/stationloving/InheritComponent(datum/component/stationloving/newc, original, _inform_admins, allow_death)
	if (original)
		if (newc)
			inform_admins = newc.inform_admins
			allow_death = newc.allow_death
		else
			inform_admins = _inform_admins

/datum/component/stationloving/proc/relocate()
	var/targetturf = find_safe_turf()
	if(!targetturf)
		if(GLOB.blobstart.len > 0)
			targetturf = get_turf(pick(GLOB.blobstart))
		else
			CRASH("Unable to find a blobstart landmark")

	var/atom/movable/AM = parent
	AM.forceMove(targetturf)
	to_chat(get(parent, /mob), span_danger("You can't help but feel that you just lost something back there..."))
	// move the disc, so ghosts remain orbiting it even if it's "destroyed"
	return targetturf

/datum/component/stationloving/proc/check_in_bounds()
	if(in_bounds())
		return
	else
		var/turf/currentturf = get_turf(src)
		var/turf/targetturf = relocate()
		log_game("[parent] has been moved out of bounds in [loc_name(currentturf)]. Moving it to [loc_name(targetturf)].")
		if(inform_admins)
			message_admins("[parent] has been moved out of bounds in [ADMIN_VERBOSEJMP(currentturf)]. Moving it to [ADMIN_VERBOSEJMP(targetturf)].")

/datum/component/stationloving/proc/check_soul_imbue()
	return disallow_soul_imbue

/datum/component/stationloving/proc/in_bounds()
	var/static/list/allowed_shuttles = typecacheof(list(/area/shuttle/syndicate, /area/shuttle/escape, /area/shuttle/pod_1, /area/shuttle/pod_2, /area/shuttle/pod_3, /area/shuttle/pod_4))
	var/static/list/disallowed_centcom_areas = typecacheof(list(/area/abductor_ship, /area/fabric_of_reality, /area/awaymission/errorroom))
	var/turf/T = get_turf_global(parent) // yogs - replace get_turf with get_turf_global
	if (!T)
		return FALSE
	var/area/A = T.loc
	if (is_station_level(T.z))
		return TRUE
	if (is_centcom_level(T.z))
		if (is_type_in_typecache(A, disallowed_centcom_areas))
			return FALSE
		return TRUE
	if (is_reserved_level(T.z))
		if (is_type_in_typecache(A, allowed_shuttles))
			return TRUE

	return FALSE

/datum/component/stationloving/proc/check_deletion(datum/source, force) // TRUE = interrupt deletion, FALSE = proceed with deletion

	var/turf/T = get_turf(parent)

	if(inform_admins && force)
		message_admins("[parent] has been !!force deleted!! in [ADMIN_VERBOSEJMP(T)].")
		log_game("[parent] has been !!force deleted!! in [loc_name(T)].")

	if(!force && !allow_death)
		var/turf/targetturf = relocate()
		log_game("[parent] has been destroyed in [loc_name(T)]. Moving it to [loc_name(targetturf)].")
		if(inform_admins)
			message_admins("[parent] has been destroyed in [ADMIN_VERBOSEJMP(T)]. Moving it to [ADMIN_VERBOSEJMP(targetturf)].")
		return TRUE
	return FALSE
