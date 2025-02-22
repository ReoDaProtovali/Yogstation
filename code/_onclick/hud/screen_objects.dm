/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/atom/movable/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = HUD_LAYER
	plane = HUD_PLANE
	animate_movement = SLIDE_STEPS
	speech_span = SPAN_ROBOT
	vis_flags = VIS_INHERIT_PLANE
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.

/atom/movable/screen/proc/update_icon()
	return

/atom/movable/screen/Destroy()
	master = null
	hud = null
	return ..()

/atom/movable/screen/examine(mob/user)
	return list()

/atom/movable/screen/orbit()
	return

/atom/movable/screen/proc/component_click(atom/movable/screen/component_button/component, params)
	return

/atom/movable/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/atom/movable/screen/swap_hand
	layer = HUD_LAYER
	plane = HUD_PLANE
	name = "swap hand"

/atom/movable/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return 1

/atom/movable/screen/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/atom/movable/screen/area_creator
	name = "create new area"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "area_edit"
	screen_loc = ui_building

/atom/movable/screen/area_creator/Click()
	if(usr.incapacitated() || (isobserver(usr) && !IsAdminGhost(usr)))
		return TRUE
	var/area/A = get_area(usr)
	if(!A.outdoors)
		to_chat(usr, span_warning("There is already a defined structure here."))
		return TRUE
	create_area(usr)

/atom/movable/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/atom/movable/screen/language_menu/Click()
	var/mob/M = usr
	var/datum/language_holder/H = M.get_language_holder()
	H.open_language_menu(usr)

/atom/movable/screen/ghost/pai
	name = "pAI Candidate"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "pai_setup"
	screen_loc = ui_ghost_pai

/atom/movable/screen/ghost/pai/Click()
	var/mob/dead/observer/G = usr
	G.register_pai()

/atom/movable/screen/ghost/med_scan
	name = "Toggle Medical Scan"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "med_scan"
	screen_loc = ui_ghost_med

/atom/movable/screen/ghost/med_scan/Click()
	var/mob/dead/observer/G = usr
	G.toggle_health_scan()

/atom/movable/screen/ghost/chem_scan
	name = "Toggle Chemical Scan"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "chem_scan"
	screen_loc = ui_ghost_chem

/atom/movable/screen/ghost/chem_scan/Click()
	var/mob/dead/observer/G = usr
	G.toggle_chemical_scan()

/atom/movable/screen/ghost/nanite_scan
	name = "Toggle Nanite Scan"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "nanite_scan"
	screen_loc = ui_ghost_nanite

/atom/movable/screen/ghost/nanite_scan/Click()
	var/mob/dead/observer/G = usr
	G.toggle_nanite_scan()

/atom/movable/screen/ghost/wound_scan
	name = "Toggle Wound Scan"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "wound_scan"
	screen_loc = ui_ghost_wound

/atom/movable/screen/ghost/wound_scan/Click()
	var/mob/dead/observer/G = usr
	G.toggle_wound_scan()

/atom/movable/screen/language_menu/ghost
	screen_loc = ui_ghost_language_menu

/atom/movable/screen/inventory
	var/slot_id	// The indentifier for the slot. It has nothing to do with ID cards.
	var/icon_empty // Icon when empty. For now used only by humans.
	var/icon_full  // Icon when contains an item. For now used only by humans.
	var/list/object_overlays = list()
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return 1

	if(hud && hud.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id))
		usr.update_inv_hands()
	return 1

/atom/movable/screen/inventory/MouseEntered()
	..()
	add_overlays()

/atom/movable/screen/inventory/MouseExited()
	..()
	cut_overlay(object_overlays)
	object_overlays.Cut()

/atom/movable/screen/inventory/update_icon()
	if(!icon_empty)
		icon_empty = icon_state

	if(hud && hud.mymob && slot_id && icon_full)
		if(hud.mymob.get_item_by_slot(slot_id))
			icon_state = icon_full
		else
			icon_state = icon_empty

/atom/movable/screen/inventory/proc/add_overlays()
	var/mob/user = hud.mymob

	if(hud && user && slot_id)
		var/obj/item/holding = user.get_active_held_item()

		if(!holding || user.get_item_by_slot(slot_id))
			return

		var/image/item_overlay = image(holding)
		item_overlay.alpha = 92

		if(!user.can_equip(holding, slot_id, TRUE))
			item_overlay.color = "#FF0000"
		else
			item_overlay.color = "#00ff00"

		object_overlays += item_overlay
		add_overlay(object_overlays)

/atom/movable/screen/inventory/hand
	var/mutable_appearance/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "blocked")
	var/held_index = 0

/atom/movable/screen/inventory/hand/update_icon()
	. = ..()

	if(!handcuff_overlay)
		var/ui_style = hud?.mymob?.client?.prefs?.read_preference(/datum/preference/choiced/ui_style)
		var/state = (!(held_index % 2)) ? "markus" : "gabrielle"
		handcuff_overlay = mutable_appearance((ui_style ? ui_style2icon(ui_style) : 'icons/mob/screen_gen.dmi'), state)

	cut_overlays()

	if(!hud?.mymob)
		return

	if(iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.handcuffed)
			add_overlay(handcuff_overlay)

		if(held_index)
			if(!C.has_hand_for_held_index(held_index))
				add_overlay(blocked_overlay)

	if(held_index == hud.mymob.active_hand_index)
		add_overlay((held_index % 2) ? "lhandactive" : "rhandactive")


/atom/movable/screen/inventory/hand/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated() || isobserver(usr))
		return 1
	if (ismecha(usr.loc)) // stops inventory actions in a mech
		return 1

	if(hud.mymob.active_hand_index == held_index)
		var/obj/item/I = hud.mymob.get_active_held_item()
		if(I)
			I.Click(location, control, params)
	else
		hud.mymob.swap_hand(held_index)
	return 1

/atom/movable/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	icon_state = "backpack_close"

/atom/movable/screen/close/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/atom/movable/screen/close/Click()
	var/datum/component/storage/S = master
	S.hide_from(usr)
	return TRUE

/atom/movable/screen/drop
	name = "drop"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_drop"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/drop/Click()
	if(usr.stat == CONSCIOUS)
		usr.dropItemToGround(usr.get_active_held_item())

/atom/movable/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/atom/movable/screen/act_intent/Click(location, control, params)
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)

/atom/movable/screen/act_intent/segmented/Click(location, control, params)
	if(usr.client.prefs.toggles & INTENT_STYLE)
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])

		if(_x<=16 && _y<=16)
			usr.a_intent_change(INTENT_HARM)

		else if(_x<=16 && _y>=17)
			usr.a_intent_change(INTENT_HELP)

		else if(_x>=17 && _y<=16)
			usr.a_intent_change(INTENT_GRAB)

		else if(_x>=17 && _y>=17)
			usr.a_intent_change(INTENT_DISARM)
	else
		return ..()

/atom/movable/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_movi

/atom/movable/screen/act_intent/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_intents

/atom/movable/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = ui_internal

/atom/movable/screen/internals/Click()
	if(!iscarbon(usr))
		return

	var/mob/living/carbon/C = usr
	if(C.incapacitated())
		return

	if(C.internal)
		C.close_internals()
		to_chat(C, span_notice("You are no longer running on internals."))
		icon_state = "internal0"
	else
		if (!C.can_breathe_internals())
			to_chat(C, span_warning("You are not wearing a suitable internals mask!"))
			return

		var/obj/item/I = C.is_holding_item_of_type(/obj/item/tank)
		if(I)
			to_chat(C, span_notice("You are now running on internals from [I] in your [C.get_held_index_name(C.get_held_index_of_item(I))]."))
			C.open_internals(I)
		else if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.s_store, /obj/item/tank))
				to_chat(H, span_notice("You are now running on internals from [H.s_store] on your [H.wear_suit.name]."))
				H.open_internals(H.s_store)
			else if(istype(H.belt, /obj/item/tank))
				to_chat(H, span_notice("You are now running on internals from [H.belt] on your belt."))
				H.open_internals(H.belt)
			else if(istype(H.l_store, /obj/item/tank))
				to_chat(H, span_notice("You are now running on internals from [H.l_store] in your left pocket."))
				H.open_internals(H.l_store)
			else if(istype(H.r_store, /obj/item/tank))
				to_chat(H, span_notice("You are now running on internals from [H.r_store] in your right pocket."))
				H.open_internals(H.r_store)

		//Separate so CO2 jetpacks are a little less cumbersome.
		if(!C.internal && istype(C.back, /obj/item/tank))
			to_chat(C, span_notice("You are now running on internals from [C.back] on your back."))
			C.open_internals(C.back)

		if(C.internal)
			icon_state = "internal1"
		else
			to_chat(C, span_warning("You don't have a suitable tank!"))
			return
	C.update_action_buttons_icon()

/atom/movable/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "running"

/atom/movable/screen/mov_intent/Click()
	toggle(usr)

/atom/movable/screen/mov_intent/update_icon(mob/user)
	if(!user && hud)
		user = hud.mymob
	if(!user)
		return
	switch(user.m_intent)
		if(MOVE_INTENT_WALK)
			icon_state = "walking"
		if(MOVE_INTENT_RUN)
			icon_state = "running"

/atom/movable/screen/mov_intent/proc/toggle(mob/user)
	if(isobserver(user))
		return
	user.toggle_move_intent(user)

/atom/movable/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "pull"

/atom/movable/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()

/atom/movable/screen/pull/update_icon(mob/mymob)
	if(!mymob)
		return
	if(mymob.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"

/atom/movable/screen/resist
	name = "resist"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_resist"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/atom/movable/screen/rest
	name = "rest"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_rest"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/rest/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.lay_down()

/atom/movable/screen/rest/update_icon(mob/mymob)
	if(!isliving(mymob))
		return
	var/mob/living/L = mymob
	if(!L.resting)
		icon_state = "act_rest"
	else
		icon_state = "act_rest0"

/atom/movable/screen/storage
	name = "storage"
	icon_state = "block"
	screen_loc = "7,7 to 10,8"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/storage/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/atom/movable/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return TRUE
	if(usr.incapacitated())
		return TRUE
	if (ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE
	if(master)
		var/obj/item/I = usr.get_active_held_item()
		if(I)
			master.attackby(null, I, usr, params)
	return TRUE

/atom/movable/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_throw_off"

/atom/movable/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BODY_ZONE_CHEST
	var/static/list/hover_overlays_cache = list()
	var/hovering

/atom/movable/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if (!choice)
		return 1

	return set_selected_zone(choice, usr)

/atom/movable/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice

	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'icons/mob/screen_gen.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= hover_overlays_cache[hovering]
		hovering = null

/atom/movable/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					return BODY_ZONE_R_LEG
				if(17 to 22)
					return BODY_ZONE_L_LEG
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_R_ARM
				if(12 to 20)
					return BODY_ZONE_PRECISE_GROIN
				if(21 to 24)
					return BODY_ZONE_L_ARM
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_R_ARM
				if(12 to 20)
					return BODY_ZONE_CHEST
				if(21 to 24)
					return BODY_ZONE_L_ARM
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							return BODY_ZONE_PRECISE_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							return BODY_ZONE_PRECISE_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							return BODY_ZONE_PRECISE_EYES
				return BODY_ZONE_HEAD

/atom/movable/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(isobserver(user))
		return

	if(choice != selecting)
		selecting = choice
		update_icon(usr)
	return 1

/atom/movable/screen/zone_sel/update_icon(mob/user)
	cut_overlays()
	add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[selecting]"))
	user.zone_selected = selecting

/atom/movable/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'

/atom/movable/screen/zone_sel/alien/update_icon(mob/user)
	cut_overlays()
	add_overlay(mutable_appearance('icons/mob/screen_alien.dmi', "[selecting]"))
	user.zone_selected = selecting

/atom/movable/screen/zone_sel/robot
	icon = 'icons/mob/screen_cyborg.dmi'


/atom/movable/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = FLASH_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/damageoverlay
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/atom/movable/screen/healths/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_alien_health

/atom/movable/screen/healths/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_health

/atom/movable/screen/healths/blob
	name = "blob health"
	icon_state = "block"
	screen_loc = ui_internal
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/blob/overmind
	name = "overmind health"
	icon = 'icons/mob/blob.dmi'
	screen_loc = ui_blobbernaut_overmind_health
	icon_state = "corehealth"

/atom/movable/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/clock
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_clock"
	screen_loc = ui_living_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/clock/gear
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "bg_gear"
	screen_loc = ui_internal

/atom/movable/screen/healths/revenant
	name = "essence"
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_revenant"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/construct
	icon = 'icons/mob/screen_construct.dmi'
	icon_state = "artificer_health0"
	screen_loc = ui_construct_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/slime
	icon = 'icons/mob/screen_slime.dmi'
	icon_state = "slime_health0"
	screen_loc = ui_slime_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/lavaland_elite
	icon = 'icons/mob/screen_elite.dmi'
	icon_state = "elite_health0"
	screen_loc = ui_living_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healthdoll
	name = "health doll"
	screen_loc = ui_healthdoll

/atom/movable/screen/healthdoll/Click()
	if (ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.check_self_for_injuries()

/atom/movable/screen/healthdoll/living
	icon_state = "fullhealth0"
	screen_loc = ui_living_healthdoll
	var/filtered = FALSE //so we don't repeatedly create the mask of the mob every update

/atom/movable/screen/mood
	name = "mood"
	icon_state = "mood5"
	screen_loc = ui_mood

/atom/movable/screen/sanity
	name = "sanity"
	icon_state = "sanity3"
	screen_loc = ui_mood

/atom/movable/screen/splash
	icon = 'icons/blank_title.png'
	icon_state = ""
	screen_loc = "1,1"
	layer = SPLASHSCREEN_LAYER
	plane = SPLASHSCREEN_PLANE
	var/client/holder

/atom/movable/screen/splash/New(client/C, visible, use_previous_title) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()

	holder = C

	if(!visible)
		alpha = 0

	if(!use_previous_title)
		if(SStitle.icon)
			icon = SStitle.icon
	else
		if(!SStitle.previous_icon)
			qdel(src)
			return
		icon = SStitle.previous_icon

	holder.screen += src

/atom/movable/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 3 SECONDS)
	else
		alpha = 0
		animate(src, alpha = 255, time = 3 SECONDS)
	if(qdel_after)
		QDEL_IN(src, 30)

/atom/movable/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()


/atom/movable/screen/component_button
	var/atom/movable/screen/parent

/atom/movable/screen/component_button/Initialize(mapload, atom/movable/screen/parent)
	. = ..()
	src.parent = parent

/atom/movable/screen/component_button/Click(params)
	if(parent)
		parent.component_click(src, params)

/atom/movable/screen/cooldown_overlay
	name = ""
	icon_state = "cooldown"
	pixel_y = 4
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM | KEEP_TOGETHER | RESET_ALPHA
	vis_flags = VIS_INHERIT_ID
	var/end_time = 0
	var/atom/movable/screen/parent_button
	var/datum/callback/callback
	var/timer

/atom/movable/screen/cooldown_overlay/Initialize(mapload, button)
	. = ..(mapload)
	parent_button = button

/atom/movable/screen/cooldown_overlay/Destroy()
	stop_cooldown()
	deltimer(timer)
	return ..()

/atom/movable/screen/cooldown_overlay/proc/start_cooldown(end_time, need_timer = TRUE)
	parent_button.color = "#8000007c"
	parent_button.vis_contents += src
	src.end_time = end_time
	set_maptext("[round((end_time - world.time) / 10, 1)]")
	if(need_timer)
		timer = addtimer(CALLBACK(src, PROC_REF(tick)), 1 SECONDS, TIMER_STOPPABLE)

/atom/movable/screen/cooldown_overlay/proc/tick()
	if(world.time >= end_time)
		stop_cooldown()
		return
	set_maptext("[round((end_time - world.time) / 10, 1)]")
	if(timer)
		timer = addtimer(CALLBACK(src, PROC_REF(tick)), 1 SECONDS, TIMER_STOPPABLE)

/atom/movable/screen/cooldown_overlay/proc/stop_cooldown()
	parent_button.color = "#ffffffff"
	parent_button.vis_contents -= src
	if(callback)
		callback.Invoke()

/atom/movable/screen/cooldown_overlay/proc/set_maptext(time)
	maptext = "<div style=\"font-size:6pt;font:'Arial Black';text-align:center;\">[time]</div>"

/proc/start_cooldown(atom/movable/screen/button, time, datum/callback/callback)
	if(!time)
		return
	var/atom/movable/screen/cooldown_overlay/cooldown = new(button, button)
	if(callback)
		cooldown.callback = callback
		cooldown.start_cooldown(time)
	else
		cooldown.start_cooldown(time, FALSE)
	return cooldown

/atom/movable/screen/stamina
	name = "stamina"
	icon_state = "stamina0"
	screen_loc = ui_stamina
