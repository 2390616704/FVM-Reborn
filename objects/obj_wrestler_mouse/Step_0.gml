// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	sprite_index = spr_wrestler_mouse
	state = ENEMY_STATE.DEAD
	timer = 0
}

event_inherited();

if global.is_paused || is_frozen || is_stun || is_scare{
	exit
}

if hp <= maxhp * hurt_rate && state != ENEMY_STATE.ACTING && state != ENEMY_STATE.DEAD && state != ENEMY_STATE.APPEAR && grid_col > 8 && not throwed{
	timer = 0
	sprite_index = spr_wrestler_mouse_throw
	state = ENEMY_STATE.APPEAR
	throwed = true
}

if state == ENEMY_STATE.ATTACK{
	state = ENEMY_STATE.ACTING
	timer = 0
}



var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
}

if state == ENEMY_STATE.ACTING{
	if (hp/maxhp  > hurt_rate) {
		image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2);
	} else {
		image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2 + attack_anim);
	}
	if timer == 10 * flash_speed{
		if instance_exists(target_plant){
			with target_plant{
				plant_apply_normal_damage(id, other.atk, other.id)
			}
		}
	}
	if timer >= attack_anim * flash_speed -1{
		state = ENEMY_STATE.NORMAL
		timer = 0
	}
}

if state == ENEMY_STATE.APPEAR{
	if (hp/maxhp  > hurt_rate) {
		image_index = floor(timer / flash_speed) mod 14;
	} else {
		image_index = floor(timer / flash_speed) mod 14 + 14;
	}
	if timer >= 14 * flash_speed -1{
		state = ENEMY_STATE.NORMAL
		timer = 0
		sprite_index = spr_wrestler_mouse
	}
	if timer == 7 * flash_speed - 1{
		enemy_throw_little_mouse(id, obj_little_wrestler_mouse, 2, 3)
	}
}