/obj/item/mmi/digital/posibrain
	name = "computer intelligence core"
	desc = "A compact cube of circuitry."
	icon = 'icons/obj/computer_brain.dmi'
	icon_state = "posibrain"
	w_class = 3

	req_access = list(access_robotics)
	locked = 0
	var/searching = 0
	var/askDelay = 10 * 60 * 1


/obj/item/mmi/digital/posibrain/attack_self(var/mob/user)
	if(brainmob && !brainmob.key && searching == 0)
		//Start the process of searching for a new user.
		user << "<span class='notice'>You depress a button and start \the [src]'s boot process.</span>"
		icon_state = "posibrain-searching"
		src.searching = 1
		var/datum/ghosttrap/G = get_ghost_trap("computer intelligence core")
		G.request_player(brainmob, "Someone is requesting a personality for a computer brain.", 60 SECONDS)
		spawn(600) reset_search()

/obj/item/mmi/digital/posibrain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(src.brainmob && src.brainmob.key) return

	src.searching = 0
	icon_state = "posibrain"

	var/turf/T = get_turf_or_move(src.loc)
	for (var/mob/M in viewers(T))
		M.show_message("<span class='notice'>\The [src] bleeps and flashes a red light. Perhaps you could try again?</span>")

/obj/item/mmi/digital/posibrain/attack_ghost(var/mob/observer/ghost/user)
	if(!searching || (src.brainmob && src.brainmob.key))
		return

	var/datum/ghosttrap/G = get_ghost_trap("computer intelligence core")
	if(!G.assess_candidate(user))
		return
	var/response = alert(user, "Are you sure you wish to possess this [src]?", "Possess [src]", "Yes", "No")
	if(response == "Yes")
		G.transfer_personality(user, brainmob)
	return

/obj/item/mmi/digital/posibrain/examine(mob/user)
	if(!..(user))
		return

	var/msg = "<span class='info'>*---------*</span>\nThis is \icon[src] \a <EM>[src]</EM>!\n[desc]\n"
	msg += "<span class='warning'>"

	if(src.brainmob && src.brainmob.key)
		switch(src.brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)	msg += "It appears to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)			msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	msg += "</span><span class='info'>*---------*</span>"
	user << msg
	return

/obj/item/mmi/digital/posibrain/emp_act(severity)
	if(!src.brainmob)
		return
	else
		switch(severity)
			if(1)
				src.brainmob.emp_damage += rand(20,30)
			if(2)
				src.brainmob.emp_damage += rand(10,20)
			if(3)
				src.brainmob.emp_damage += rand(0,10)
	..()

/obj/item/mmi/digital/posibrain/PickName()
	src.brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[random_id(type,100,999)]"
	src.brainmob.real_name = src.brainmob.name
