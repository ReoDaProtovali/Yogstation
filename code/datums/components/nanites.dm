/datum/component/nanites
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/mob/living/host_mob
	var/nanite_volume = 100		//amount of nanites in the system, used as fuel for nanite programs
	var/max_nanites = 500		//maximum amount of nanites in the system
	var/regen_rate = 0.5		//nanites generated per second
	var/safety_threshold = 50	//how low nanites will get before they stop processing/triggering
	var/cloud_id = 0 			//0 if not connected to the cloud, 1-100 to set a determined cloud backup to draw from
	var/next_sync = 0
	var/list/datum/nanite_program/programs = list()
	var/max_programs = NANITE_PROGRAM_LIMIT

	var/stealth = FALSE //if TRUE, does not appear on HUDs and health scans, and does not display the program list on nanite scans

/datum/component/nanites/Initialize(amount = 100, cloud = 0)
	if(!isliving(parent) && !istype(parent, /datum/nanite_cloud_backup))
		return COMPONENT_INCOMPATIBLE

	nanite_volume = amount
	cloud_id = cloud

	//Nanites without hosts are non-interactive through normal means
	if(isliving(parent))
		host_mob = parent

		if(iscarbon(host_mob))
			var/mob/living/carbon/carbon_occupant = host_mob
			if((NONANITES in carbon_occupant.dna.species.species_traits))
				return COMPONENT_INCOMPATIBLE
		else
			if((issilicon(host_mob))) //Shouldn't happen, but this avoids HUD runtimes in case a silicon gets them somehow.
				return COMPONENT_INCOMPATIBLE

		host_mob.hud_set_nanite_indicator()
		START_PROCESSING(SSnanites, src)

		if(cloud_id)
			cloud_sync()
/datum/component/nanites/proc/delete_nanites()
	qdel(src)

/datum/component/nanites/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HAS_NANITES, PROC_REF(confirm_nanites))
	RegisterSignal(parent, COMSIG_NANITE_UI_DATA, PROC_REF(nanite_ui_data))
	RegisterSignal(parent, COMSIG_NANITE_GET_PROGRAMS, PROC_REF(get_programs))
	RegisterSignal(parent, COMSIG_NANITE_SET_VOLUME, PROC_REF(set_volume))
	RegisterSignal(parent, COMSIG_NANITE_ADJUST_VOLUME, PROC_REF(adjust_nanites))
	RegisterSignal(parent, COMSIG_NANITE_SET_MAX_VOLUME, PROC_REF(set_max_volume))
	RegisterSignal(parent, COMSIG_NANITE_SET_CLOUD, PROC_REF(set_cloud))
	RegisterSignal(parent, COMSIG_NANITE_SET_SAFETY, PROC_REF(set_safety))
	RegisterSignal(parent, COMSIG_NANITE_SET_REGEN, PROC_REF(set_regen))
	RegisterSignal(parent, COMSIG_NANITE_ADD_PROGRAM, PROC_REF(add_program))
	RegisterSignal(parent, COMSIG_NANITE_SCAN, PROC_REF(nanite_scan))
	RegisterSignal(parent, COMSIG_NANITE_SYNC, PROC_REF(sync))
	RegisterSignal(parent, COMSIG_NANITE_DELETE, PROC_REF(delete_nanites))

	if(isliving(parent))
		RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
		RegisterSignal(parent, COMSIG_GLOB_MOB_DEATH, PROC_REF(on_death))
		RegisterSignal(parent, COMSIG_MOB_ALLOWED, PROC_REF(check_access))
		RegisterSignal(parent, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_shock))
		RegisterSignal(parent, COMSIG_LIVING_MINOR_SHOCK, PROC_REF(on_minor_shock))
		RegisterSignal(parent, COMSIG_SPECIES_GAIN, PROC_REF(check_viable_biotype))
		RegisterSignal(parent, COMSIG_NANITE_SIGNAL, PROC_REF(receive_signal))
		RegisterSignal(parent, COMSIG_NANITE_COMM_SIGNAL, PROC_REF(receive_comm_signal))

/datum/component/nanites/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HAS_NANITES,
								COMSIG_NANITE_UI_DATA,
								COMSIG_NANITE_GET_PROGRAMS,
								COMSIG_NANITE_SET_VOLUME,
								COMSIG_NANITE_ADJUST_VOLUME,
								COMSIG_NANITE_SET_MAX_VOLUME,
								COMSIG_NANITE_SET_CLOUD,
								COMSIG_NANITE_SET_SAFETY,
								COMSIG_NANITE_SET_REGEN,
								COMSIG_NANITE_ADD_PROGRAM,
								COMSIG_NANITE_SCAN,
								COMSIG_NANITE_SYNC,
								COMSIG_ATOM_EMP_ACT,
								COMSIG_GLOB_MOB_DEATH,
								COMSIG_MOB_ALLOWED,
								COMSIG_LIVING_ELECTROCUTE_ACT,
								COMSIG_LIVING_MINOR_SHOCK,
								COMSIG_MOVABLE_HEAR,
								COMSIG_SPECIES_GAIN,
								COMSIG_NANITE_SIGNAL,
								COMSIG_NANITE_COMM_SIGNAL,
								COMSIG_NANITE_DELETE))

/datum/component/nanites/Destroy()
	STOP_PROCESSING(SSnanites, src)
	set_nanite_bar(TRUE)
	QDEL_LIST(programs)
	if(host_mob)
		host_mob.hud_set_nanite_indicator()
	host_mob = null
	return ..()

/datum/component/nanites/InheritComponent(datum/component/nanites/new_nanites, i_am_original, _amount, _cloud)
	if(new_nanites)
		adjust_nanites(null, new_nanites.nanite_volume)
	else
		adjust_nanites(null, _amount) //just add to the nanite volume

/datum/component/nanites/process(delta_time)
	adjust_nanites(null, regen_rate * delta_time)
	add_research()
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_process()
	set_nanite_bar()
	if(cloud_id && world.time > next_sync)
		cloud_sync()
		next_sync = world.time + NANITE_SYNC_DELAY

//Syncs the nanite component to another, making it so programs are the same with the same programming (except activation status)
/datum/component/nanites/proc/sync(datum/signal_source, datum/component/nanites/source, full_overwrite = TRUE, copy_activation = FALSE)
	var/list/programs_to_remove = programs.Copy()
	var/list/programs_to_add = source.programs.Copy()
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		for(var/Y in programs_to_add)
			var/datum/nanite_program/SNP = Y
			if(NP.type == SNP.type)
				programs_to_remove -= NP
				programs_to_add -= SNP
				SNP.copy_programming(NP, copy_activation)
				break
	if(full_overwrite)
		for(var/X in programs_to_remove)
			qdel(X)
	for(var/X in programs_to_add)
		var/datum/nanite_program/SNP = X
		add_program(null, SNP.copy())

/datum/component/nanites/proc/cloud_sync()
	if(!cloud_id)
		return
	var/datum/nanite_cloud_backup/backup = SSnanites.get_cloud_backup(cloud_id)
	if(backup)
		var/datum/component/nanites/cloud_copy = backup.nanites
		if(cloud_copy)
			sync(null, cloud_copy)

/datum/component/nanites/proc/add_program(datum/source, datum/nanite_program/new_program, datum/nanite_program/source_program)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		if(NP.unique && NP.type == new_program.type)
			qdel(NP)
	if(programs.len >= max_programs)
		return COMPONENT_PROGRAM_NOT_INSTALLED
	if(source_program)
		source_program.copy_programming(new_program)
	programs += new_program
	new_program.on_add(src)
	return COMPONENT_PROGRAM_INSTALLED

/datum/component/nanites/proc/consume_nanites(amount, force = FALSE)
	if(!force && safety_threshold && (nanite_volume - amount < safety_threshold))
		return FALSE
	adjust_nanites(null, -amount)
	return (nanite_volume > 0)

/datum/component/nanites/proc/adjust_nanites(datum/source, amount)
	nanite_volume = clamp(nanite_volume + amount, 0, max_nanites)
	if(nanite_volume <= 0) //oops we ran out
		qdel(src)

/datum/component/nanites/proc/set_nanite_bar(remove = FALSE)
	var/image/holder = host_mob.hud_list[DIAG_NANITE_FULL_HUD]
	var/icon/I = icon(host_mob.icon, host_mob.icon_state, host_mob.dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = null
	if(remove || stealth)
		return //bye icon
	var/nanite_percent = (nanite_volume / max_nanites) * 100
	nanite_percent = clamp(CEILING(nanite_percent, 10), 10, 100)
	holder.icon_state = "nanites[nanite_percent]"

/datum/component/nanites/proc/on_emp(datum/source, severity)
	var/datum/component/empprotection/empproof = host_mob.GetExactComponent(/datum/component/empprotection)
	if(empproof && (empproof.getEmpFlags() & EMP_PROTECT_SELF))
		return // don't do EMP effects if they're protected from EMPs
	nanite_volume *= (rand(0.75, 0.90))		//Lose 10-25% of nanites
	adjust_nanites(null, -(rand(5, 30)))		//Lose 5-30 flat nanite volume
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_emp(severity)
	addtimer(VARSET_CALLBACK(src, cloud_id, cloud_id), NANITE_SYNC_DELAY, TIMER_UNIQUE)//return it to normal, intentionally missing the next sync timer
	cloud_id = 0 //temporarily disable resyncing so rogue programs actually have a chance to do something

/datum/component/nanites/proc/on_shock(datum/source, shock_damage)
	nanite_volume *= (rand(0.65, 0.90))		//Lose 10-35% of nanites
	adjust_nanites(null, -(rand(5, 50)))			//Lose 5-50 flat nanite volume
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_shock(shock_damage)

/datum/component/nanites/proc/on_minor_shock(datum/source)
	adjust_nanites(null, -(rand(5, 15)))			//Lose 5-15 flat nanite volume
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_minor_shock()

/datum/component/nanites/proc/on_death(datum/source, gibbed)
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_death(gibbed)

/datum/component/nanites/proc/receive_signal(datum/source, code, signal_source = "an unidentified source")
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.receive_signal(code, signal_source)

/datum/component/nanites/proc/receive_comm_signal(datum/source, comm_code, comm_message, comm_source = "an unidentified source")
	for(var/X in programs)
		if(istype(X, /datum/nanite_program/triggered/comm))
			var/datum/nanite_program/triggered/comm/NP = X
			NP.receive_comm_signal(comm_code, comm_message, comm_source)

/datum/component/nanites/proc/check_viable_biotype()
	if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes) && !isipc(host_mob))
		qdel(src) //bodytype no longer sustains nanites

/datum/component/nanites/proc/check_access(datum/source, obj/O)
	for(var/datum/nanite_program/triggered/access/access_program in programs)
		if(access_program.activated)
			return O.check_access_list(access_program.access)
		else
			return FALSE
	return FALSE

/datum/component/nanites/proc/set_volume(datum/source, amount)
	nanite_volume = clamp(amount, 0, max_nanites)

/datum/component/nanites/proc/set_max_volume(datum/source, amount)
	max_nanites = max(1, max_nanites)

/datum/component/nanites/proc/set_cloud(datum/source, amount)
	cloud_id = clamp(amount, 0, 100)

/datum/component/nanites/proc/set_safety(datum/source, amount)
	safety_threshold = clamp(amount, 0, max_nanites)

/datum/component/nanites/proc/set_regen(datum/source, amount)
	regen_rate = amount

/datum/component/nanites/proc/confirm_nanites()
	return TRUE //yup i exist

/datum/component/nanites/proc/get_data(list/nanite_data)
	nanite_data["nanite_volume"] = nanite_volume
	nanite_data["max_nanites"] = max_nanites
	nanite_data["cloud_id"] = cloud_id
	nanite_data["regen_rate"] = regen_rate
	nanite_data["safety_threshold"] = safety_threshold
	nanite_data["stealth"] = stealth

/datum/component/nanites/proc/get_programs(datum/source, list/nanite_programs)
	nanite_programs |= programs

/datum/component/nanites/proc/add_research()
	var/research_value = NANITE_BASE_RESEARCH
	if(!ishuman(host_mob))	
		if(!iscarbon(host_mob))
			research_value *= 0.4
		else
			research_value *= 0.8
	if(!host_mob.client)
		research_value *= 0.5
	if(host_mob.stat == DEAD)
		research_value *= 0.75
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_NANITES = research_value))
	SSresearch.ruin_tech.add_point_list(list(TECHWEB_POINT_TYPE_NANITES = research_value))

/datum/component/nanites/proc/nanite_scan(datum/source, mob/user, full_scan)
	if(!full_scan)
		if(!stealth)
			to_chat(user, span_notice("<b>Nanites Detected</b>"))
			to_chat(user, span_notice("Saturation: [nanite_volume]/[max_nanites]"))
			return TRUE
	else
		to_chat(user, span_info("NANITES DETECTED"))
		to_chat(user, span_info("================"))
		to_chat(user, span_info("Saturation: [nanite_volume]/[max_nanites]"))
		to_chat(user, span_info("Safety Threshold: [safety_threshold]"))
		to_chat(user, span_info("Cloud ID: [cloud_id ? cloud_id : "Disabled"]"))
		to_chat(user, span_info("================"))
		to_chat(user, span_info("Program List:"))
		if(stealth)
			to_chat(user, span_alert("%#$ENCRYPTED&^@"))
		else
			for(var/X in programs)
				var/datum/nanite_program/NP = X
				to_chat(user, span_info("<b>[NP.name]</b> | [NP.activated ? "Active" : "Inactive"]"))
		return TRUE

/datum/component/nanites/proc/nanite_ui_data(datum/source, list/data, scan_level)
	data["has_nanites"] = TRUE
	data["nanite_volume"] = nanite_volume
	data["regen_rate"] = regen_rate
	data["safety_threshold"] = safety_threshold
	data["cloud_id"] = cloud_id
	var/list/mob_programs = list()
	var/id = 1
	for(var/X in programs)
		var/datum/nanite_program/P = X
		var/list/mob_program = list()
		mob_program["name"] = P.name
		mob_program["desc"] = P.desc
		mob_program["id"] = id

		if(scan_level >= 2)
			mob_program["activated"] = P.activated
			mob_program["use_rate"] = P.use_rate
			mob_program["can_trigger"] = P.can_trigger
			mob_program["trigger_cost"] = P.trigger_cost
			mob_program["trigger_cooldown"] = P.trigger_cooldown / 10

		if(scan_level >= 3)
			mob_program["activation_delay"] = P.activation_delay
			mob_program["timer"] = P.timer
			mob_program["timer_type"] = P.get_timer_type_text()
			var/list/extra_settings = list()
			for(var/Y in P.extra_settings)
				var/list/setting = list()
				setting["name"] = Y
				setting["value"] = P.get_extra_setting(Y)
				extra_settings += list(setting)
			mob_program["extra_settings"] = extra_settings
			if(LAZYLEN(extra_settings))
				mob_program["has_extra_settings"] = TRUE

		if(scan_level >= 4)
			mob_program["activation_code"] = P.activation_code
			mob_program["deactivation_code"] = P.deactivation_code
			mob_program["kill_code"] = P.kill_code
			mob_program["trigger_code"] = P.trigger_code
		id++
		mob_programs += list(mob_program)
	data["mob_programs"] = mob_programs
