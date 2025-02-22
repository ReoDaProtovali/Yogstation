/obj/item/gun/ballistic/automatic
	w_class = WEIGHT_CLASS_NORMAL
	var/select = 1
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
	semi_auto = TRUE
	fire_sound = "sound/weapons/smgshot.ogg"
	fire_sound_volume = 80
	vary_fire_sound = FALSE
	rack_sound = "sound/weapons/smgrack.ogg"
	feedback_fire_slide = TRUE
	feedback_types = list(
		"fire" = 2
	)

/obj/item/gun/ballistic/automatic/proto
	name = "\improper Nanotrasen Saber SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	pin = null
	bolt_type = BOLT_TYPE_LOCKING
	mag_display = TRUE

/obj/item/gun/ballistic/automatic/proto/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/update_icon()
	..()
	if(!select)
		add_overlay("[initial(icon_state)]_semi")
	if(select == 1)
		add_overlay("[initial(icon_state)]_burst")

/obj/item/gun/ballistic/automatic/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_firemode))
		burst_select()
	else
		..()

/obj/item/gun/ballistic/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	var/spread_difference = initial(spread) - semi_auto_spread //Set this way so laser sights work properly. Default value of 0
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		spread -= spread_difference //Has to be subtraction because laser sight
		to_chat(user, span_notice("You switch to semi-automatic."))
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		spread += spread_difference //Has to be addition because laser sight
		to_chat(user, span_notice("You switch to [burst_size]-rnd burst."))

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/gun/ballistic/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A bullpup two-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_delay = 2
	burst_size = 2
	pin = /obj/item/firing_pin/implant/pindicate
	can_bayonet = TRUE
	knife_x_offset = 26
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE

/obj/item/gun/ballistic/automatic/c20r/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/c20r/Initialize()
	. = ..()
	update_icon()

/obj/item/gun/ballistic/automatic/wt550
	name = "\improper security auto carbine"
	desc = "An outdated personal defence weapon. Uses 4.6x30mm rounds and is designated the WT-550 Automatic Carbine. Has a two-round burst or a semi-automatic firing mode."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_delay = 2
	burst_size = 2
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	can_suppress = TRUE // its been 6 years, get with the times old man!
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE

/obj/item/gun/ballistic/automatic/wt550/armory
	starting_mag_type = /obj/item/ammo_box/magazine/wt550m9/wtr

/obj/item/gun/ballistic/automatic/mini_uzi
	name = "\improper Type U3 Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "miniuzi"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	burst_size = 2
	bolt_type = BOLT_TYPE_OPEN
	mag_display = TRUE
	rack_sound = "sound/weapons/pistollock.ogg"

/obj/item/gun/ballistic/automatic/m90
	name = "\improper M-90gl Rifle"
	desc = "A three-round burst 5.56 toploading rifle, designated 'M-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "m90"
	item_state = "m90"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = FALSE
	var/obj/item/gun/ballistic/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2
	pin = /obj/item/firing_pin/implant/pindicate
	mag_display = TRUE
	empty_indicator = TRUE

/obj/item/gun/ballistic/automatic/m90/Initialize()
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher(src)
	update_icon()

/obj/item/gun/ballistic/automatic/m90/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/m90/unrestricted/Initialize()
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted(src)
	update_icon()

/obj/item/gun/ballistic/automatic/m90/afterattack(atom/target, mob/living/user, flag, params)
	if(select == 2)
		underbarrel.afterattack(target, user, flag, params)
	else
		return ..()

/obj/item/gun/ballistic/automatic/m90/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		if(istype(A, underbarrel.magazine.ammo_type))
			underbarrel.attack_self()
			underbarrel.attackby(A, user, params)
	else
		..()

/obj/item/gun/ballistic/automatic/m90/update_icon()
	..()
	switch(select)
		if(0)
			add_overlay("[initial(icon_state)]_semi")
		if(1)
			add_overlay("[initial(icon_state)]_burst")
		if(2)
			add_overlay("[initial(icon_state)]_gren")
	return

/obj/item/gun/ballistic/automatic/m90/burst_select()
	var/mob/living/carbon/human/user = usr
	var/spread_difference = initial(spread) - semi_auto_spread //It shouldn't need this but just in case someone decides to nerf the M90-gl's accuracy for whatever reason
	switch(select)
		if(0)
			select = 1
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			spread += spread_difference
			to_chat(user, span_notice("You switch to [burst_size]-rnd burst."))
		if(1)
			select = 2
			to_chat(user, span_notice("You switch to grenades."))
		if(2)
			select = 0
			burst_size = 1
			fire_delay = 0
			spread -= spread_difference
			to_chat(user, span_notice("You switch to semi-auto."))
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

/obj/item/gun/ballistic/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "Based on the classic 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = FALSE
	burst_size = 4
	spread = 30
	fire_delay = 1
	bolt_type = BOLT_TYPE_OPEN

/obj/item/gun/ballistic/automatic/ar
	name = "\improper NT-ARG 'Boarder' Rifle"
	desc = "A robust assault rifle used by Nanotrasen fighting forces."
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/r556
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 1


// L6 SAW //

/obj/item/gun/ballistic/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 7.12x82mm light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2506' engraved on the receiver below the designation."
	icon_state = "l6"
	item_state = "l6closedmag"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/mm712x82
	weapon_weight = WEAPON_HEAVY
	var/cover_open = FALSE
	can_suppress = FALSE
	fire_delay = 1
	burst_size = 3
	spread = 14
	pin = /obj/item/firing_pin/implant/pindicate
	bolt_type = BOLT_TYPE_OPEN
	mag_display = TRUE
	mag_display_ammo = TRUE
	tac_reloads = FALSE
	automatic = TRUE
	fire_sound = 'sound/weapons/rifleshot.ogg'
	rack_sound = 'sound/weapons/chunkyrack.ogg'

/obj/item/gun/ballistic/automatic/l6_saw/unrestricted
	pin = /obj/item/firing_pin


/obj/item/gun/ballistic/automatic/l6_saw/examine(mob/user)
	. = ..()
	. += "<b>alt + click</b> to [cover_open ? "close" : "open"] the dust cover."
	if(cover_open && magazine)
		. += span_notice("It seems like you could use an <b>empty hand</b> to remove the magazine.")


/obj/item/gun/ballistic/automatic/l6_saw/AltClick(mob/user)
	cover_open = !cover_open
	to_chat(user, span_notice("You [cover_open ? "open" : "close"] [src]'s cover."))
	if(cover_open)
		playsound(user, 'sound/weapons/sawopen.ogg', 60, 1)
	else
		playsound(user, 'sound/weapons/sawopen.ogg', 60, 1)
	update_icon()


/obj/item/gun/ballistic/automatic/l6_saw/update_icon()
	. = ..()
	add_overlay("l6_door_[cover_open ? "open" : "closed"]")


/obj/item/gun/ballistic/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params)
	if(cover_open)
		to_chat(user, span_warning("[src]'s cover is open! Close it before firing!"))
		return
	else
		. = ..()
		update_icon()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/automatic/l6_saw/attack_hand(mob/user)
	if (loc != user)
		..()
		return
	if (!cover_open)
		to_chat(user, span_warning("[src]'s cover is closed! Open it before trying to remove the magazine!"))
		return
	..()

/obj/item/gun/ballistic/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, mag_type))
		to_chat(user, span_warning("[src]'s dust cover prevents a magazine from being fit."))
		return
	..()



// LWT-650 DMR //

/obj/item/gun/ballistic/automatic/lwt650
	name = "\improper LWT-650 DMR"
	desc = "A long-barreled designated marksman rifle vaguely based on the WT platform. Slowly fires powerful .308 rounds."
	icon_state = "lwt650"
	item_state = "lwt650"
	fire_sound = "sound/weapons/dmrshot.ogg"
	vary_fire_sound = FALSE //Pure DMR bliss my beloved
	load_sound = "sound/weapons/rifleload.ogg"
	load_empty_sound = "sound/weapons/rifleload.ogg"
	rack_sound = "sound/weapons/riflerack.ogg"
	eject_sound = "sound/weapons/rifleunload.ogg"
	eject_empty_sound = "sound/weapons/rifleunload.ogg"
	mag_type = /obj/item/ammo_box/magazine/m308
	fire_delay = 6
	burst_size = 1
	spread = 2 //Marksman rifle == accurate?
	can_suppress = FALSE
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 12
	actions_types = list() //So you can't avoid the fire_delay
	mag_display = TRUE
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY

// K-41s DMR //

/obj/item/gun/ballistic/automatic/k41s
	name = "\improper K-41s DMR"
	desc = "A sleek, urban camouflage rifle that fires powerful 7.62mm rounds. Comes with a mid-range scope."
	icon_state = "dmr"
	item_state = "dmr"
	fire_sound = "sound/weapons/dmrshot.ogg"
	fire_sound_volume = 70 //Might be too loud
	vary_fire_sound = FALSE
	load_sound = "sound/weapons/rifleload.ogg"
	load_empty_sound = "sound/weapons/rifleload.ogg"
	rack_sound = "sound/weapons/riflerack.ogg"
	eject_sound = "sound/weapons/rifleunload.ogg"
	eject_empty_sound = "sound/weapons/rifleunload.ogg"
	mag_type = /obj/item/ammo_box/magazine/ks762
	fire_delay = 5 //Can fire slightly faster than the LWT-650
	burst_size = 1
	spread = 2 //DMR gets to be special
	can_suppress = FALSE
	zoomable = TRUE
	zoom_amt = 5 //Not as significant a scope as the sniper
	actions_types = list() //So you can't avoid the fire_delay
	pin = /obj/item/firing_pin/implant/pindicate
	mag_display = TRUE
	empty_indicator = TRUE
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_NORMAL //Just stuff it in the bag

/obj/item/gun/ballistic/automatic/k41s/unrestricted
	pin = /obj/item/firing_pin

// SNIPER //

/obj/item/gun/ballistic/automatic/sniper_rifle
	name = "\improper sniper rifle"
	desc = "A long ranged weapon that does significant damage. No, you can't quickscope."
	icon_state = "sniper"
	item_state = "sniper"
	fire_sound = "sound/weapons/sniper_shot.ogg"
	fire_sound_volume = 90
	vary_fire_sound = FALSE
	load_sound = "sound/weapons/sniper_mag_insert.ogg"
	rack_sound = "sound/weapons/sniper_rack.ogg"
	recoil = 2
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	fire_delay = 40
	burst_size = 1
	spread = 0
	w_class = WEIGHT_CLASS_NORMAL
	zoomable = TRUE
	zoom_amt = 10 //Long range, enough to see in front of you, but no tiles behind you.
	zoom_out_amt = 5
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	mag_display = TRUE

/obj/item/gun/ballistic/automatic/sniper_rifle/syndicate
	name = "\improper syndicate sniper rifle"
	desc = "An illegally modified .50 cal sniper rifle with suppression compatibility. Quickscoping still doesn't work."
	can_suppress = TRUE
	can_unsuppress = TRUE
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/automatic/sniper_rifle/ultrasecure
	pin = /obj/item/firing_pin/fucked

// Old Semi-Auto Carbine //

/obj/item/gun/ballistic/automatic/surplus
	name = "\improper surplus carbine"
	desc = "One of several antique carbines that still sees use as a cheap deterrent. Uses .45 ammo, and its bulky frame prevents one-hand firing."
	icon_state = "surplus"
	item_state = "moistnugget"
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/m10mm/rifle
	fire_delay = 10
	burst_size = 1
	can_unsuppress = TRUE
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	mag_display = TRUE
	can_bayonet = TRUE

// Laser rifle (rechargeable magazine) //

/obj/item/gun/ballistic/automatic/laser
	name = "\improper laser rifle"
	desc = "Though sometimes mocked for the relatively weak firepower of their energy weapons, the logistic miracle of rechargeable ammunition has given Nanotrasen a decisive edge over many a foe."
	icon_state = "oldrifle"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/recharge
	fire_delay = 2
	can_suppress = FALSE
	burst_size = 0
	actions_types = list()
	fire_sound = 'sound/weapons/laser.ogg'
	casing_ejector = FALSE
