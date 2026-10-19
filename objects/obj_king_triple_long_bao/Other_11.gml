var _target_rows = target_rows;
var _row_count = array_length(_target_rows);
if (_row_count <= 0) exit;

var _bullet_index = 0;
var _target_row = 0;
var _inst = noone;
for(var i = 0 ; i < array_length(bullet_list) ; i++){
	for(var j = 0 ; j < 3 ; j++){
		_target_row = _target_rows[0];
		if (_bullet_index < 3 && _bullet_index < _row_count) {
			_target_row = _target_rows[_bullet_index];
		}
		_inst = instance_create_depth(x + 20*i + 12*j,y-80,depth-500,bullet_list[i].bullet_type);
		_inst.damage = bullet_list[i].damage;
		_inst.move_speed = 8;
		_inst.row = grid_row;
		_inst.start_y = y-80;
		_inst.target_row = _target_row;
		_bullet_index++;
	}
}