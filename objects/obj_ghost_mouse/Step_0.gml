// Inherit the parent event
if global.is_paused{
	exit
}

event_inherited();

if is_frozen || is_stun{
	exit
}

if state == ENEMY_STATE.ACTING{
	timer++

	var current_move_speed = move_speed
	if is_slowdown{
		current_move_speed = move_speed / 2
	}
	if hp > maxhp*hurt_rate{
		image_index = floor(timer/flash_speed) mod move_anim
	}
	else{
		image_index = floor(timer/flash_speed) mod move_anim + move_anim
	}
	x -= current_move_speed
}


