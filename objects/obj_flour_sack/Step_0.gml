// Inherit the parent event
if global.is_paused{
	alarm[0] = alarm_get(0) + 1
	alarm[1] = alarm_get(1) + 1
	exit
}
ice_timer = 0
frozen_timer = 0
event_inherited();

if origin_row == -1{
	origin_row = grid_row
	origin_col = grid_col
}

orbit_charge++
var charge_ready = false
if orbit_charge >= FLOUR_SACK_CHARGE_STEPS{
	orbit_charge = 0
	charge_ready = true
}

if payload_active{
	flour_sack_capture_step(id)
	if array_length(orbit_visuals) > 0{
		flour_sack_update_orbit(id)
	}
	x += chspeed
	y += cvspeed
	exit
}

if (global.selected_slot == noone && !(instance_exists(obj_shovel_slot) && obj_shovel_slot.is_selected)) {
	if (mouse_check_button_pressed(mb_left) && position_meeting(mouse_x, mouse_y, id)) {
		flour_sack_try_jump(id)
	}
}

if state == CARD_STATE.IDLE{
	if charge_ready && array_length(orbit_visuals) > 0{
		flour_sack_try_launch(id)
	}
	flour_sack_capture_step(id)
	if array_length(orbit_visuals) > 0{
		flour_sack_update_orbit(id)
	}
}

if state == CARD_STATE.IDLE{
	flash_speed = 6
}
else{
	var delay = 0
	if shape == 0{
		delay = 20
	}
	else{
		delay = 65
	}
	if attack_timer == 1{
		global.audio.play(snd_flour_sack_find,0,0)
	}
	if attack_timer <=delay{
		attack_timer ++
		if instance_exists(banding_star_obj){
			banding_star_obj.x = self.x
			banding_star_obj.y = self.y-5
		}
	}
	else{
		
		event_user(1)
		attack_timer = -9999999
	}
	flash_speed = 4
}


	x += chspeed
	y += cvspeed


