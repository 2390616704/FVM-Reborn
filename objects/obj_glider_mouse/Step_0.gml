// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0 && state != ENEMY_STATE.DEAD && !death_pending && glider_airborne) {
	if (state == ENEMY_STATE.APPEAR || state == ENEMY_STATE.ACTING) {
		death_pending = true;
		target_plant = noone;
		if (state != ENEMY_STATE.ACTING) {
			state = ENEMY_STATE.ACTING;
			sprite_index = spr_glider_mouse_drop;
			anim_timer = 0;
		}
	}
}
event_inherited();

if (is_frozen || is_scare || is_stun) exit;

var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
}

if (state != ENEMY_STATE.DEAD && (hp > 0 || death_pending)) {
	if state == ENEMY_STATE.APPEAR{
		anim_timer++
		x -= current_move_speed * move_speed_modify
		image_index = floor(anim_timer/flash_speed) mod 6
		if x <= global.grid_offset_x + 150{
			state = ENEMY_STATE.ACTING
			sprite_index = spr_glider_mouse_drop
			anim_timer = 0
		}
		else {
			glider_try_swap(id)
		}
	}
	if state == ENEMY_STATE.ACTING{
		target_type = "normal"
		anim_timer++
		image_index = floor(anim_timer/flash_speed) mod 6
		if anim_timer >= flash_speed * 6{
			sprite_index = spr_glider_mouse_land
			anim_timer = 0
			helmet_hp = 0
			glider_airborne = false
			if death_pending{
				death_pending = false
				hp = 0
				state = ENEMY_STATE.DEAD
			}
			else{
				state = ENEMY_STATE.NORMAL
				move_speed = 0.36
			}
		}
	}
}
