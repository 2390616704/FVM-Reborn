if global.is_paused{
	exit
}
timer++
if timer <= 17 * 5 - 1{
	image_index = floor(timer /5) mod 17
	image_alpha = timer/20
	if timer <= 20{
		y += 15
	}
}
else{
	image_index = 16
	image_alpha-= 0.1
	if image_alpha <= 0
	instance_destroy()
}
if timer == 21{
	with obj_card_parent{
		if grid_col == other.target_col && grid_row == other.target_row &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			plant_apply_boss_lethal(id)
		}
	}
}