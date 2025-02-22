/* HUD DATUMS */

GLOBAL_LIST_EMPTY(all_huds)

//GLOBAL HUD LIST
GLOBAL_LIST_INIT(huds, list(
	DATA_HUD_SECURITY_BASIC = 		new/datum/atom_hud/data/human/security/basic(),
	DATA_HUD_SECURITY_ADVANCED = 	new/datum/atom_hud/data/human/security/advanced(),
	DATA_HUD_MEDICAL_BASIC = 		new/datum/atom_hud/data/human/medical/basic(),
	DATA_HUD_MEDICAL_ADVANCED = 	new/datum/atom_hud/data/human/medical/advanced(),
	DATA_HUD_DIAGNOSTIC_BASIC = 	new/datum/atom_hud/data/diagnostic/basic(),
	DATA_HUD_DIAGNOSTIC_ADVANCED = 	new/datum/atom_hud/data/diagnostic/advanced(),
	DATA_HUD_ABDUCTOR = 			new/datum/atom_hud/abductor(),
	DATA_HUD_SENTIENT_DISEASE = 	new/datum/atom_hud/sentient_disease(),
	DATA_HUD_AI_DETECT = 			new/datum/atom_hud/ai_detector(),
	DATA_HUD_SECURITY_MEDICAL = 	new/datum/atom_hud/data/human/security/advanced/hos(),
	ANTAG_HUD_CULT = 		new/datum/atom_hud/antag(),
	ANTAG_HUD_REV = 		new/datum/atom_hud/antag(),
	ANTAG_HUD_OPS = 		new/datum/atom_hud/antag(),
	ANTAG_HUD_WIZ = 		new/datum/atom_hud/antag(),
	ANTAG_HUD_SHADOW = 		new/datum/atom_hud/antag(),
	ANTAG_HUD_TRAITOR = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_NINJA = 		new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_CHANGELING = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_ABDUCTOR = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_DEVIL = 		new/datum/atom_hud/antag(),
	ANTAG_HUD_SINTOUCHED = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_SOULLESS = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_CLOCKWORK = 	new/datum/atom_hud/antag(),
	ANTAG_HUD_BROTHER = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_HIVE = 		new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_OBSESSED = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_FUGITIVE = 	new/datum/atom_hud/antag(),
	ANTAG_HUD_VAMPIRE = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_DARKSPAWN = 	new/datum/atom_hud/antag(),
	ANTAG_HUD_CAPITALIST = 	new/datum/atom_hud/antag(),
	ANTAG_HUD_COMMUNIST = 	new/datum/atom_hud/antag(),
	ANTAG_HUD_HERETIC = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_MINDSLAVE = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_ZOMBIE = 		new/datum/atom_hud/antag(),
	ANTAG_HUD_INFILTRATOR = new/datum/atom_hud/antag(),
	ANTAG_HUD_BLOODSUCKER = new/datum/atom_hud/antag(),
	ANTAG_HUD_MHUNTER = 	new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_BRAINWASHED = new/datum/atom_hud/antag/hidden()
	))

/datum/atom_hud
	var/list/atom/hudatoms = list() //list of all atoms which display this hud
	var/list/hudusers = list() //list with all mobs who can see the hud
	var/list/hud_icons = list() //these will be the indexes for the atom's hud_list

	var/list/next_time_allowed = list() //mobs associated with the next time this hud can be added to them
	var/list/queued_to_see = list() //mobs that have triggered the cooldown and are queued to see the hud, but do not yet

	var/do_silicon_check = FALSE // true for medical and sec advanced and diagnostic basic HUDs

/datum/atom_hud/New()
	GLOB.all_huds += src

/datum/atom_hud/Destroy()
	for(var/v in hudusers)
		remove_hud_from(v)
	for(var/v in hudatoms)
		remove_from_hud(v)
	GLOB.all_huds -= src
	return ..()

/datum/atom_hud/proc/remove_hud_from(mob/M, absolute = FALSE)
	if(!M || !hudusers[M])
		return
	if (absolute || !--hudusers[M])
		UnregisterSignal(M, COMSIG_PARENT_QDELETING)
		var/M_is_silicon = FALSE
		if(do_silicon_check && istype(M, /mob/living/silicon))
			M_is_silicon = TRUE
		hudusers -= M
		if(next_time_allowed[M])
			next_time_allowed -= M
		if(queued_to_see[M])
			queued_to_see -= M
		else
			for(var/atom/A in hudatoms)
				if(M_is_silicon)
					if (istype(A, /mob))
						var/mob/B = A
						if(B.digitalcamo)
							continue
				remove_from_single_hud(M, A)

/datum/atom_hud/proc/remove_from_hud(atom/A)	//this is called when some stops existing or needs HUD removed
	if(!A)
		return FALSE
	var/has_camo = FALSE
	if(do_silicon_check && istype(A, /mob))
		var/mob/B = A
		if(B.digitalcamo)
			has_camo = TRUE
	for(var/mob/M in hudusers)
		if(has_camo)
			if(istype(M, /mob/living/silicon))
				continue
		remove_from_single_hud(M, A)
	hudatoms -= A
	return TRUE

/datum/atom_hud/proc/remove_from_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client	this is used to Hide HUD A from mob M
	if(!M || !M.client || !A)
		return
	for(var/i in hud_icons)
		M.client.images -= A.hud_list[i]

/datum/atom_hud/proc/add_hud_to(mob/M)	// this is called when something activates HUD
	if(!M)
		return
	if(!hudusers[M])
		hudusers[M] = 1
		RegisterSignal(M, COMSIG_PARENT_QDELETING, PROC_REF(unregister_mob))
		var/M_is_silicon = FALSE
		if(do_silicon_check && istype(M, /mob/living/silicon))
			M_is_silicon = TRUE
		if(next_time_allowed[M] > world.time)
			if(!queued_to_see[M])
				addtimer(CALLBACK(src, PROC_REF(show_hud_images_after_cooldown), M, M_is_silicon), next_time_allowed[M] - world.time)
				queued_to_see[M] = TRUE
		else
			next_time_allowed[M] = world.time + ADD_HUD_TO_COOLDOWN
			for(var/atom/A in hudatoms)
				if(M_is_silicon)
					if(istype(A, /mob))
						var/mob/B = A
						if(B.digitalcamo)
							continue
				add_to_single_hud(M, A)
	else
		hudusers[M]++		// the hell does this do?

/datum/atom_hud/proc/unregister_mob(datum/source, force)
	SIGNAL_HANDLER
	remove_hud_from(source, TRUE)

/datum/atom_hud/proc/show_hud_images_after_cooldown(M, M_is_silicon)
	if(queued_to_see[M])
		queued_to_see -= M
		next_time_allowed[M] = world.time + ADD_HUD_TO_COOLDOWN
		for(var/atom/A in hudatoms)
			if(M_is_silicon)
				if(istype(A, /mob))
					var/mob/B = A
					if(B.digitalcamo)
						continue
			add_to_single_hud(M, A)

/datum/atom_hud/proc/add_to_hud(atom/A)	// something new starts existing or is in a need of a HUD
	if(!A)
		return FALSE
	hudatoms |= A
	var/has_camo = FALSE
	if(do_silicon_check && istype(A, /mob))
		var/mob/B = A
		if(B.digitalcamo)
			has_camo = TRUE
	for(var/mob/M in hudusers)
		if(has_camo)
			if(istype(M, /mob/living/silicon))
				continue
		if(!queued_to_see[M])
			add_to_single_hud(M, A)
	return TRUE

/datum/atom_hud/proc/add_to_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client		this is used to show hud A to mob M
	if(!M || !M.client || !A)
		return
	for(var/i in hud_icons)
		if(A.hud_list[i])
			M.client.images |= A.hud_list[i]

//MOB PROCS
/mob/proc/reload_huds()		// used when you need to readd all aplicable huds to user (for instance on reconnect)
	for(var/datum/atom_hud/hud in GLOB.all_huds)
		if(hud && hud.hudusers[src])
			for(var/atom/A in hud.hudatoms)
				hud.add_to_single_hud(src, A)

/mob/dead/new_player/reload_huds()
	return

/mob/proc/add_click_catcher()
	client.screen += client.void

/mob/dead/new_player/add_click_catcher()
	return
