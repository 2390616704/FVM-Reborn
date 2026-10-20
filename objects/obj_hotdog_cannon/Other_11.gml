var row_offset = (target_row - grid_row) * global.grid_cell_size_y
var spawn_y = y - 65 + row_offset
if has_air{
	spawn_y = y - 125 + row_offset
}
var inst = instance_create_depth(x+40,spawn_y,depth-500,obj_hotdogcannon_bullet)
inst.damage = atk
inst.move_speed = 8
inst.row = target_row
inst.target_y = spawn_y
if has_air{
	inst.target_type = "air_only"
}