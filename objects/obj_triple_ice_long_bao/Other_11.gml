var _target_rows = target_rows;
var _row_count = array_length(_target_rows);
if (_row_count <= 0) exit;

var _inst = noone;
for (var i = 0; i < min(3, _row_count); i++) {
	_inst = instance_create_depth(x+40,y-75,depth-500,obj_icelongbao_bullet);
	_inst.damage = atk;
	_inst.move_speed = 8;
	_inst.row = grid_row;
	_inst.start_y = y-75;
	_inst.target_row = _target_rows[i];
}

if (_row_count < 3) {
	var inst2 = instance_create_depth(x,y-95,depth-500,obj_icelongbao_bullet_vertical);
	inst2.damage = atk;
	inst2.move_speed = 8;
	inst2.col = grid_col;
	inst2.image_angle = -90;
}

if (_row_count < 2) {
	var inst3 = instance_create_depth(x,y-95,depth-500,obj_icelongbao_bullet_vertical);
	inst3.damage = atk;
	inst3.move_speed = -8;
	inst3.col = grid_col;
	inst3.image_angle = 90;
}