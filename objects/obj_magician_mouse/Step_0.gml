// Inherit the parent event

if global.is_paused{
	exit
}
if (hp <= 0) {
	sprite_index = spr_magician_mouse
	if state != ENEMY_STATE.DEAD{
	    timer = 0;
	    state = ENEMY_STATE.DEAD;
	}
    target_plant = noone;  // 清除攻击目标
}

event_inherited();

if is_frozen || is_stun{
	exit
}



var current_cycle = 0
var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
	current_cycle = cycle*2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
	current_cycle = cycle
}

if state == ENEMY_STATE.APPEAR{
	if hp > 0{
		anim_timer++
		x -= current_move_speed
		image_index = floor(anim_timer/flash_speed) mod 6
		if x <= get_world_position_from_grid(global.grid_extra_left + 9,grid_row).x{
			anim_timer = 0
			sprite_index = spr_magician_mouse
			state = ENEMY_STATE.ACTING
		}
	}
}

if state == ENEMY_STATE.ACTING{
	
	attack_timer++
	if attack_timer < current_cycle - flash_speed * attack_anim{
		if (hp/maxhp > hurt_rate) {
			image_index = floor(timer / flash_speed) mod move_anim;
		} else {
			image_index = (floor(timer / flash_speed) mod move_anim) + move_anim;
		}
	}
	else if attack_timer < current_cycle{
		anim_timer++
		if (hp/maxhp > hurt_rate) {
			image_index = floor(anim_timer / flash_speed) mod attack_anim + move_anim * 2; 
		} else {
			image_index = (floor(anim_timer / flash_speed) mod attack_anim) + move_anim * 2 + attack_anim;
		}
		if attack_timer == current_cycle - flash_speed * 17{
			enemy_throw_little_mouse(id, obj_little_magician_mouse, 4, 6)
		}
	}
	else{
		attack_timer = 0
		anim_timer = 0
	}
}