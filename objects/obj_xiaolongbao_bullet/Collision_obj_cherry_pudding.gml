if (variable_instance_exists(id, "flour_sack_captured") && flour_sack_captured) {
	exit
}

if !bounced && row == other.grid_row{
	move_speed *= -1
	damage += other.atk
	image_angle += 180
	bounced = true
}