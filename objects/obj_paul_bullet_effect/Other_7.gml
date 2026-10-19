with obj_card_parent{
	if(grid_col == other.col && grid_row == other.row && plant_id != "player" && plant_type != "lilypad" && plant_type != "coffee"){
		plant_apply_boss_lethal(id, other)
	}
}

instance_destroy()