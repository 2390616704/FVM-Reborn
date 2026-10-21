function glider_try_swap(glider) {
	if (!instance_exists(glider)) return;

	var _front_col = 999999;
	var _rear = noone;
	var _rear_col = -999999;

	with (obj_enemy_parent) {
		if (id == glider.id) continue;
		if (hp <= 0 || state == ENEMY_STATE.DEAD) continue;
		if (grid_row != glider.grid_row) continue;
		if (target_type == "obstacle") continue;

		if (grid_col < _front_col) _front_col = grid_col;

		if (target_type == "normal" && !is_boss && !giant_type && grid_col > _rear_col) {
			_rear_col = grid_col;
			_rear = id;
		}
	}

	if (_rear == noone) return;
	if (glider.grid_col > _front_col) return;
	if (abs(glider.x - _rear.x) < 1) return;

	var _glider_x = glider.x;
	var _glider_col = glider.grid_col;

	glider.x = _rear.x;
	glider.grid_col = _rear.grid_col;
	glider.target_plant = noone;

	_rear.x = _glider_x;
	_rear.grid_col = _glider_col;
	_rear.target_plant = noone;
}
