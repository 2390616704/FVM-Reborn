if global.is_paused{
	exit
}
timer++

if state == "start"{
	x -= 8
	image_index = floor(timer/5) mod 8
	if x <= get_world_position_from_grid(global.grid_extra_left + 0,0).x{
		state = "corner"
	}
	
	with obj_card_parent{
		if grid_col == other.target_col && grid_row == other.target_row && plant_type != "lilypad" &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			other.state = "corner"
			if plant_id != "sugar_roxburghii"{
				plant_apply_boss_lethal(id, other)
			}
			break
		}
	}
}
if state == "corner"{
	x -= 8
	image_index = floor(timer/5) mod 8
	
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
	
}

var grid_pos = get_grid_position_from_world(x,y)
target_col = grid_pos.col
target_row = grid_pos.row