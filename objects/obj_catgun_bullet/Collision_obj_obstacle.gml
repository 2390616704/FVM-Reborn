if (variable_instance_exists(id, "flour_sack_captured") && flour_sack_captured) {
	exit
}

if target_type == "normal" && row == other.row{
	instance_destroy()
}