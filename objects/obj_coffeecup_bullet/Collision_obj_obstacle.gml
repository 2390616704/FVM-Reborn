if (variable_instance_exists(id, "flour_sack_captured") && flour_sack_captured) {
	exit
}

if target_type == "normal" && row == other.row{
	instance_create_depth(x,y,depth,obj_coffeecup_bullet_effect)
	instance_destroy()
}