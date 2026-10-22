// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
	sprite_index = spr_trumpeter_mouse
}

event_inherited();



if global.is_paused || is_frozen || is_stun{
	exit
}
if state != ENEMY_STATE.DEAD{
	if perform_timer < perform_cooldown{
		perform_timer++
	}
	else{
		if state != ENEMY_STATE.ACTING{
			timer = 0
			state = ENEMY_STATE.ACTING
			sprite_index = spr_trumpeter_mouse_perform
		}
	}

	if state = ENEMY_STATE.ACTING{
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 19
		}
		else{
			image_index = floor(timer/flash_speed) mod 19 + 19
		}
		if timer == flash_speed * 19 - 1{
			with obj_enemy_parent{
				if point_distance(x,y,other.x,other.y) <= 250 && scare_timer <= 0 && left_move_flashs <= 0{
					var _row_offset = grid_row - other.grid_row;
					if abs(_row_offset) >= 1 && abs(_row_offset) <= 2{
						var _from_row = min(grid_row, other.grid_row);
						var _to_row = max(grid_row, other.grid_row);
						var _base_feature = global.row_feature[clamp(other.grid_row, 0, global.grid_rows - 1)];
						var _same_feature = true;
						for (var _r = _from_row; _r <= _to_row; _r++){
							if global.row_feature[clamp(_r, 0, global.grid_rows - 1)] != _base_feature{
								_same_feature = false;
								break;
							}
						}
						if _same_feature{
							scare_timer = 30
							left_move_flashs = 30
							y_move = -_row_offset * global.grid_cell_size_y / left_move_flashs
						}
					}
				}
			}
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_trumpeter_mouse
			timer = 0
			perform_timer = 0
		}
	}
}