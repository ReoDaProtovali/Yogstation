/mob/living/proc/phaseout(obj/effect/decal/cleanable/B)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		for(var/obj/item/I in C.held_items)
			//TODO make it toggleable to either forcedrop the items, or deny
			//entry when holding them
			// literally only an option for carbons though
			to_chat(C, span_warning("You may not hold items while blood crawling!"))
			return 0
		var/obj/item/bloodcrawl/B1 = new(C)
		var/obj/item/bloodcrawl/B2 = new(C)
		B1.icon_state = "bloodhand_left"
		B2.icon_state = "bloodhand_right"
		C.put_in_hands(B1)
		C.put_in_hands(B2)
		C.regenerate_icons()
	src.notransform = TRUE
	spawn(0)
		bloodpool_sink(B)
		src.notransform = FALSE
	return 1

/mob/living/proc/bloodpool_sink(obj/effect/decal/cleanable/B)
	var/turf/mobloc = get_turf(src.loc)

	src.visible_message(span_warning("[src] sinks into the pool of blood!"))
	playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 50, 1, -1)
	// Extinguish, unbuckle, stop being pulled, set our location into the
	// dummy object
	var/obj/effect/dummy/phased_mob/holder = new /obj/effect/dummy/phased_mob(mobloc)
	src.ExtinguishMob()

	// Keep a reference to whatever we're pulling, because forceMove()
	// makes us stop pulling
	var/pullee = src.pulling

	src.holder = holder
	src.forceMove(holder)

	// if we're not pulling anyone, or we can't eat anyone
	if(!pullee || src.bloodcrawl != BLOODCRAWL_EAT)
		return

	// if the thing we're pulling isn't alive
	if (!isliving(pullee))
		return

	var/mob/living/victim = pullee
	var/kidnapped = FALSE

	if(victim.stat == CONSCIOUS)
		src.visible_message(span_warning("[victim] kicks free of the blood pool just before entering it!"), null, span_notice("You hear splashing and struggling."))
	else if(victim.reagents?.has_reagent(/datum/reagent/consumable/ethanol/demonsblood, needs_metabolizing = TRUE))
		visible_message(span_warning("Something prevents [victim] from entering the pool!"), span_warning("A strange force is blocking [victim] from entering!"), span_notice("You hear a splash and a thud."))
	else
		victim.forceMove(src)
		victim.emote("scream")
		src.visible_message(span_warning("<b>[src] drags [victim] into the pool of blood!</b>"), null, span_notice("You hear a splash."))
		kidnapped = TRUE

	if(kidnapped)
		var/success = bloodcrawl_consume(victim)
		if(!success)
			to_chat(src, span_danger("You happily devour... nothing? Your meal vanished at some point!"))
	return 1

/mob/living/proc/bloodcrawl_consume(mob/living/victim)
	to_chat(src, span_danger("You begin to feast on [victim]. You can not move while you are doing this."))

	var/sound
	if(istype(src, /mob/living/simple_animal/slaughter))
		var/mob/living/simple_animal/slaughter/SD = src
		sound = SD.feast_sound
	else
		sound = 'sound/magic/demon_consume.ogg'

	for(var/i in 1 to 3)
		playsound(get_turf(src),sound, 50, 1)
		sleep(3 SECONDS)

	if(!victim)
		return FALSE

	if(victim.reagents?.has_reagent(/datum/reagent/consumable/ethanol/devilskiss, needs_metabolizing = TRUE))
		to_chat(src, span_warning("<b>AAH! THEIR FLESH! IT BURNS!</b>"))
		adjustBruteLoss(25) //I can't use adjustHealth() here because bloodcrawl affects /mob/living and adjustHealth() only affects simple mobs
		var/found_bloodpool = FALSE
		for(var/obj/effect/decal/cleanable/target in range(1,get_turf(victim)))
			if(target.can_bloodcrawl_in())
				victim.forceMove(get_turf(target))
				victim.visible_message(span_warning("[target] violently expels [victim]!"))
				victim.exit_blood_effect(target)
				found_bloodpool = TRUE

		if(!found_bloodpool)
			// Fuck it, just eject them, thanks to some split second cleaning
			victim.forceMove(get_turf(victim))
			victim.visible_message(span_warning("[victim] appears from nowhere, covered in blood!"))
			victim.exit_blood_effect()
		return TRUE

	to_chat(src, span_danger("You devour [victim]. Your health is fully restored."))
	src.revive(full_heal = 1)

	// No defib possible after laughter
	victim.adjustBruteLoss(1000)
	victim.death()
	bloodcrawl_swallow(victim)
	return TRUE

/mob/living/proc/bloodcrawl_swallow(var/mob/living/victim)
	qdel(victim)

/obj/item/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	item_flags = ABSTRACT | DROPDEL

/obj/item/bloodcrawl/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/mob/living/proc/exit_blood_effect(obj/effect/decal/cleanable/B)
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 50, 1, -1)
	//Makes the mob have the color of the blood pool it came out of
	var/newcolor = rgb(149, 10, 10)
	if(istype(B, /obj/effect/decal/cleanable/xenoblood))
		newcolor = rgb(43, 186, 0)
	add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	// but only for a few seconds
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, newcolor), 6 SECONDS)

/mob/living/proc/phasein(obj/effect/decal/cleanable/B)
	if(src.notransform)
		to_chat(src, span_warning("Finish eating first!"))
		return 0
	B.visible_message(span_warning("[B] starts to bubble..."))
	if(!do_after(src, 2 SECONDS, B))
		return
	if(!B)
		return
	forceMove(B.loc)
	src.client.eye = src
	src.visible_message(span_warning("<B>[src] rises out of the pool of blood!</B>"))
	exit_blood_effect(B)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		for(var/obj/item/bloodcrawl/BC in C)
			BC.flags_1 = null
			qdel(BC)
	qdel(src.holder)
	src.holder = null
	return 1
