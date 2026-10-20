if global.is_paused{
	exit
}

x -= 8
with obj_card_parent{
	if abs(x-other.x) <= 50 && grid_row == other.grid_row{
		var inst = instance_create_depth(x,y-35,-800,obj_arno_bullet_effect)
		inst.sprite_index = spr_mouse_train_1_bullet_effect
		if plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			plant_apply_boss_lethal(id, other)
		}
	}
}
if x < -200{
	instance_destroy()
}