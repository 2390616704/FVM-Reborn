if global.is_paused{
	
	image_speed = 0
	exit
}
image_speed = 1
if burnt == 1{
	sprite_index = spr_xiaolongbao_bullet
}
else if burnt == 2{
	sprite_index = spr_fire_bullet
}
x += move_speed * BULLET_SPEED_SCALE
if target_row >= 0{
	var target_y = global.grid_offset_y + global.grid_cell_size_y * target_row;
	y = lerp(y, target_y, 0.48);
	if abs(y - target_y) < 30{
		row = target_row;
	}
}
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}