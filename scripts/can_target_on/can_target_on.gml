function can_target_on(card_target_type,enemy_target_type){
	if enemy_target_type == "normal"{
		if card_target_type != "air_only"{
			return true
		}
	}
	if enemy_target_type == "diver"{
		if card_target_type == "throw" || card_target_type == "track" || card_target_type == "rotate"  || card_target_type == "d_fruit"{
			return true
		}
	}
	if enemy_target_type == "air"{
		if card_target_type == "air" || card_target_type == "track" || card_target_type == "air_only" || card_target_type == "rotate"{
			return true
		}
	}
	if enemy_target_type == "dance"{
		if card_target_type == "pierce" || card_target_type == "rotate"  || card_target_type == "d_fruit"{
			return true
		}
	}
	if enemy_target_type == "obstacle"{
		if card_target_type == "pierce" || card_target_type == "normal" || card_target_type == "rotate" || card_target_type == "d_fruit"{
			return true
		}
	}
	if enemy_target_type == "underground"{
		if card_target_type == "rotate" || card_target_type == "d_fruit"{
			return true
		}
	}
	if card_target_type == "all"{
		return true
	}
	return false
}

function can_hit(bullet_target_type,enemy_target_type){
	return can_target_on(bullet_target_type,enemy_target_type)
}

function get_leftmost_target_rows(_plant) {
	var _rows = [];
	if (!instance_exists(_plant)) return _rows;
	var _row_cols = array_create(global.grid_rows, 999999);
	var _plant_col = _plant.grid_col;
	var _plant_row = _plant.grid_row;
	var _plant_target_type = _plant.target_type;

	with (obj_enemy_parent) {
		if (hp > 0 && grid_col >= _plant_col && grid_col <= global.grid_cols + 1 &&
			grid_row >= 0 && grid_row < global.grid_rows &&
			can_target_on(_plant_target_type, target_type) &&
			grid_col < _row_cols[grid_row]) {
			_row_cols[grid_row] = grid_col;
		}
	}

	for (var r = 0; r < global.grid_rows; r++) {
		if (_row_cols[r] < 999999) {
			array_push(_rows, r);
		}
	}

	for (var i = 1; i < array_length(_rows); i++) {
		var _row = _rows[i];
		var _col = _row_cols[_row];
		var _dist = abs(_row - _plant_row);
		var j = i - 1;
		while (j >= 0) {
			var _prev = _rows[j];
			var _prev_col = _row_cols[_prev];
			var _prev_dist = abs(_prev - _plant_row);
			if (_prev_col < _col ||
				(_prev_col == _col && (_prev_dist < _dist ||
				(_prev_dist == _dist && _prev < _row)))) {
				break;
			}
			_rows[j + 1] = _prev;
			j--;
		}
		_rows[j + 1] = _row;
	}

	return _rows;
}