/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/c38_sec
	name = "Speed Loader (.38 rubber)"
	desc = "Designed to quickly reload revolvers."
	id = "sec_38"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000)
	build_path = /obj/item/ammo_box/c38/rubber
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_sec/lethal
	name = "Speed Loader (.38)"
	id = "sec_38_lethal"
	build_path = /obj/item/ammo_box/c38
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/rubbershot/sec
	id = "sec_rshot"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/beanbag_slug/sec
	id = "sec_beanbag_slug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/shotgun_slug/sec
	id = "sec_slug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/buckshot_shell/sec
	id = "sec_bshot"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/shotgun_dart/sec
	id = "sec_dart"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/incendiary_slug/sec
	id = "sec_Islug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/breaching_slug/sec
	name = "Breaching Slug"
	desc = "A 12 gauge anti-material slug. Great for breaching airlocks and windows with minimal shots."
	id = "sec_Brslug"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/breacher
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pin_testing
	name = "Test-Range Firing Pin"
	desc = "This safety firing pin allows firearms to be operated within proximity to a firing range."
	id = "pin_testing"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 300)
	build_path = /obj/item/firing_pin/test_range
	category = list("Firing Pins")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/stunmine/sec //mines ported from BeeStation
	name = "Stun Mine"
	desc = "A basic non-lethal stunning mine. Stuns anyone who walks over it."
	id = "stunmine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000)
	build_path = /obj/item/deployablemine/stun
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/adv_stunmine/sec
	name = "Smart Stun Mine"
	desc = "An advanced non-lethal stunning mine. Uses advanced detection software to only trigger when activated by someone without a mindshield implant."
	id = "stunmine_adv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 3000, /datum/material/silver = 200)
	build_path = /obj/item/deployablemine/smartstun
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/lm6_stunmine/sec
	name = "Rapid Deployment Smartmine"
	desc = "An advanced non-lethal stunning mine. Uses advanced detection software to only trigger when activated by someone without a mindshield implant. Can be rapidly placed and disarmed."
	id = "stunmine_rapid"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/silver = 500, /datum/material/uranium = 200)
	build_path = /obj/item/deployablemine/rapid
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/lm12_stunmine/sec
	name = "Sledgehammer Smartmine"
	desc = "An advanced non-lethal stunning mine. Uses advanced detection software to only trigger when activated by someone without a mindshield implant. Very powerful and hard to disarm."
	id = "stunmine_heavy"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/silver = 500, /datum/material/uranium = 200)
	build_path = /obj/item/deployablemine/heavy
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/honkmine
	name = "Honkblaster 1000"
	desc = "An advanced pressure activated pranking mine, honk!"
	id = "clown_mine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/bananium = 500)
	build_path = /obj/item/deployablemine/honk
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/stunrevolver
	name = "Tesla Revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	id = "stunrevolver"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 10000)
	build_path = /obj/item/gun/energy/tesla_revolver
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2000, /datum/material/uranium = 3000, /datum/material/titanium = 1000)
	build_path = /obj/item/gun/energy/e_gun/nuclear
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/ntusp_conversion
	name = "NT-USP Conversion Kit"
	desc = "A standard conversion kit for use in converting NT-USP magazines to be more lethal or less lethal."
	id = "ntusp_conversion"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 200, /datum/material/silver = 200)
	build_path = /obj/item/ntusp_conversion_kit
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/tele_shield
	name = "Telescopic Riot Shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	id = "tele_shield"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 4000, /datum/material/silver = 300, /datum/material/titanium = 200)
	build_path = /obj/item/shield/riot/tele
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/beamrifle
	name = "Beam Marksman Rifle"
	desc = "A powerful long ranged anti-material rifle that fires charged particle beams to obliterate targets."
	id = "beamrifle"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000, /datum/material/diamond = 5000, /datum/material/uranium = 8000, /datum/material/silver = 4500, /datum/material/gold = 5000)
	build_path = /obj/item/gun/energy/beam_rifle
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 5000,/datum/material/uranium = 10000)
	reagents_list = list(/datum/reagent/toxin/mutagen = 40)
	build_path = /obj/item/gun/energy/decloner
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/syringegun
	name = "Syringe Gun"
	desc = "A gun that fires syringes."
	id = "syringegun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000)
	build_path = /obj/item/gun/syringe
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY | DEPARTMENTAL_FLAG_MEDICAL	//uwu

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that shoots temperature energy beams to change temperature."
	id = "temp_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 500, /datum/material/silver = 3000)
	build_path = /obj/item/gun/energy/temperature
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 500)
	reagents_list = list(/datum/reagent/uranium/radium = 20)
	build_path = /obj/item/gun/energy/floragun
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and uses larger containers."
	id = "large_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/grenade/chem_grenade/large
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/pyro_grenade
	name = "Pyro Grenade"
	desc = "An advanced grenade that is able to self ignite its mixture."
	id = "pyro_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/plasma = 500)
	build_path = /obj/item/grenade/chem_grenade/pyro
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cryo_grenade
	name = "Cryo Grenade"
	desc = "An advanced grenade that rapidly cools its contents upon detonation."
	id = "cryo_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	build_path = /obj/item/grenade/chem_grenade/cryo
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/adv_grenade
	name = "Advanced Release Grenade"
	desc = "An advanced grenade that can be detonated several times, best used with a repeating igniter."
	id = "adv_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500)
	build_path = /obj/item/grenade/chem_grenade/adv_release
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/xray
	name = "X-ray Laser Gun"
	desc = "Not quite as menacing as it sounds."
	id = "xray_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 5000, /datum/material/uranium = 4000, /datum/material/iron = 5000, /datum/material/titanium = 2000, /datum/material/bluespace = 2000)
	build_path = /obj/item/gun/energy/xray
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/ioncarbine
	name = "Ion Carbine"
	desc = "How to dismantle a cyborg: The gun."
	id = "ioncarbine"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 6000, /datum/material/iron = 8000, /datum/material/uranium = 2000)
	build_path = /obj/item/gun/energy/ionrifle/carbine
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/wormhole_projector
	name = "Bluespace Wormhole Projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	id = "wormholeprojector"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 2000, /datum/material/iron = 5000, /datum/material/diamond = 2000, /datum/material/bluespace = 3000)
	build_path = /obj/item/gun/energy/wormhole_projector
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

//WT550 Mags

/datum/design/mag_oldsmg
	name = "WT-550 Auto Gun Magazine (4.6x30mm)"
	desc = "A 20-round magazine for the out of date security WT-550 Auto Carbine."
	id = "mag_oldsmg"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_box/magazine/wt550m9
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/mag_oldsmg/ap_mag
	name = "WT-550 Auto Gun Armour Piercing Magazine (4.6x30mm AP)"
	desc = "A 20-round armour piercing magazine for the out of date security WT-550 Auto Carbine."
	id = "mag_oldsmg_ap"
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 600)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtap
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/mag_oldsmg/ic_mag
	name = "WT-550 Auto Gun Incendiary Magazine (4.6x30mm IC)"
	desc = "A 20-round incendiary magazine for the out of date security WT-550 Auto Carbine."
	id = "mag_oldsmg_ic"
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 600, /datum/material/glass = 1000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtic
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/mag_oldsmg/rubber_mag
	name = "WT-550 Auto Gun Rubber Bullet Magazine (4.6x30mm Rubber)"
	desc = "A 20-round rubber bullet magazine for the out of date security WT-550 Auto Carbine."
	id = "mag_oldsmg_rubber"
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtr
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

	// This is where the fun begins

/datum/design/mag_oldsmg/kraken_mag
	name = "WT-550 Auto Gun Kraken Bullet Magazine (4.6x30mm Kraken)"
	desc = "A 20-round kraken magazine for the out of date security WT-550 Auto Carbine."
	id = "mag_oldsmg_kraken"
	materials = list(/datum/material/iron = 7500, /datum/material/titanium = 2000, /datum/material/diamond = 500)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wt_kraken
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/mag_oldsmg/snakebite_mag
	name = "WT-550 Auto Gun snakebite Bullet Magazine (4.6x30mm snakebite)"
	desc = "A 20-round snakebite magazine for the out of date security WT-550 Auto Carbine."
	id = "mag_oldsmg_snakebite"
	materials = list(/datum/material/iron = 7500, /datum/material/titanium = 2000, /datum/material/uranium = 1000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wt_snakebite
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

//Vatra M38 Magazines

/datum/design/mag_v38
	name = "Vatra M38 Magazine (.38)"
	desc = "A 8-round magazine for the Vatra M38 service handgun."
	id = "mag_v38"
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/ammo_box/magazine/v38
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/mag_v38/ap_mag
	name = "Vatra M38 Magazine (.38 armor-piercing)"
	desc = "A 8-round armor-piercing magazine for the Vatra M38 service handgun."
	id = "mag_v38_ap"
	materials = list(/datum/material/iron = 3000, /datum/material/silver = 450)
	build_path = /obj/item/ammo_box/magazine/v38/ap

/datum/design/mag_v38/rubber_mag
	name = "Vatra M38 Rubber Magazine (.38 rubber)"
	desc = "A 8-round rubber magazine for the Vatra M38 service handgun."
	id = "mag_v38_rubber"
	build_path = /obj/item/ammo_box/magazine/v38/rubber
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_v38/frost_mag
	name = "Vatra M38 Frost Magazine (.38 frost)"
	desc = "A 8-round frost magazine for the Vatra M38 service handgun."
	id = "mag_v38_frost"
	materials = list(/datum/material/iron = 3000, /datum/material/silver = 450, /datum/material/diamond = 400)
	build_path = /obj/item/ammo_box/magazine/v38/frost

/datum/design/mag_v38/talon_mag
	name = "Vatra M38 Talon Magazine (.38 talon)"
	desc = "A 8-round talon magazine for the Vatra M38 service handgun."
	id = "mag_v38_talon"
	materials = list(/datum/material/iron = 3000, /datum/material/silver = 450, /datum/material/glass = 750)
	build_path = /obj/item/ammo_box/magazine/v38/talon

/datum/design/mag_v38/bluespace_mag
	name = "Vatra M38 Bluespace Magazine (.38 bluespace)"
	desc = "A 8-round bluespace magazine for the Vatra M38 service handgun."
	id = "mag_v38_bluespace"
	materials = list(/datum/material/iron = 4000, /datum/material/titanium = 1500, /datum/material/plasma = 450, /datum/material/bluespace = 400)
	build_path = /obj/item/ammo_box/magazine/v38/bluespace

/datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/ammo_casing/shotgun/stunslug
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/techshell
	name = "Unloaded Technological Shotshell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	id = "techshotshell"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200)
	build_path = /obj/item/ammo_casing/shotgun/techshell
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/suppressor
	name = "Suppressor"
	desc = "A reverse-engineered suppressor that fits on most small arms with threaded barrels."
	id = "suppressor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	build_path = /obj/item/suppressor
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/gravitygun
	name = "One-point Bluespace-gravitational Manipulator"
	desc = "A multi-mode device that blasts one-point bluespace-gravitational bolts that locally distort gravity."
	id = "gravitygun"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 8000, /datum/material/uranium = 8000, /datum/material/glass = 12000, /datum/material/iron = 12000, /datum/material/diamond = 3000, /datum/material/bluespace = 3000)
	build_path = /obj/item/gun/energy/gravity_gun
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hardlightbow
	name = "Hardlight Bow"
	desc = "A modern bow that can fabricate hardlight arrows using an internal energy."
	id = "hardlightbow"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1500, /datum/material/uranium = 1500, /datum/material/silver = 1500)
	build_path = /obj/item/gun/ballistic/bow/energy
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/vib_blade
	name = "Vibration Blade"
	desc = "A hard-light blade vibrating at rapid pace, enabling you to cut through armor and flesh with ease."
	id = "vib_blade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/silver = 2500, /datum/material/gold = 1000)
	build_path = /obj/item/melee/transforming/vib_blade
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_ARMORY

/datum/design/mindflayer
	name = "Mind Flayer"
	desc = "A compact weapon made to destroy the brain."
	id = "mind_flayer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 3000, /datum/material/plasma = 1000, /datum/material/dilithium = 100)
	build_path = /obj/item/gun/energy/mindflayer
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/bouncer
	name = "Bouncer Energy Gun"
	desc = "An atypical energy gun shooting bouncing projectiles."
	id = "bouncer_egun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 10000, /datum/material/silver = 1000, /datum/material/titanium = 1200)
	reagents_list = list(/datum/reagent/sorium = 20)
	build_path = /obj/item/gun/energy/e_gun/bouncer
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/simple_sight
	name = "Simple Sight"
	desc = "A simple yet elegant scope. Better than ironsights."
	id = "simple_sight"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2500)
	build_path = /obj/item/attachment/scope/simple
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/holo_sight
	name = "Holographic Sight"
	desc = "A highly advanced sight that projects a holographic design onto its lens, providing unobscured and precise view of your target."
	id = "holo_sight"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2500, /datum/material/gold = 1000, /datum/material/plastic = 1000)
	build_path = /obj/item/attachment/scope/holo
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/vert_grip
	name = "Vertical Grip"
	desc = "A tactile grip that increases the control and steadiness of your weapon."
	id = "vert_grip"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 2500)
	build_path = /obj/item/attachment/grip/vertical
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/laser_sight
	name = "Laser Sight"
	desc = "A glorified laser pointer. Good for knowing what you're aiming at."
	id = "laser_sight"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/gold = 1000, /datum/material/uranium = 1000, /datum/material/glass = 500)
	build_path = /obj/item/attachment/laser_sight
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/infra_sight
	name = "Infrared Sight"
	desc = "A polarizing camera that picks up infrared radiation. The quality is rather poor, so it ends up making it harder to aim."
	id = "infra_sight"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2500, /datum/material/uranium = 1500, /datum/material/gold = 1000, /datum/material/plastic = 1000)
	build_path = /obj/item/attachment/scope/infrared
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
