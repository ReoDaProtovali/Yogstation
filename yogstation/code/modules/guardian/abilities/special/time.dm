/datum/guardian_ability/major/special/timestop
	name = "Time Stop"
	desc = "The guardian can stop time in a localized area."
	cost = 5
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian

/datum/guardian_ability/major/special/timestop/Berserk()
	guardian.RemoveSpell(spell)
	spell = new /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian/berserk
	guardian.AddSpell(spell)

/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian
	invocation_type = SPELL_INVOCATION_NONE
	clothes_req = FALSE
	summon_type = list(/obj/effect/timestop)

/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian/berserk
	summon_type = list(/obj/effect/timestop/berserk)

/obj/effect/timestop/berserk
	name = "lagfield"
	desc = "Oh no. OH NO."
	freezerange = 4
	duration = 175
	pixel_x = -64
	pixel_y = -64
	start_sound = 'yogstation/sound/effects/unnatural_clock_noises.ogg'

/obj/effect/timestop/berserk/Initialize(mapload, radius, time, list/immune_atoms, start)
	. = ..()
	var/matrix/ntransform = matrix(transform)
	ntransform.Scale(2)
	animate(src, transform = ntransform, time = 0.2 SECONDS, easing = EASE_IN|EASE_OUT)
