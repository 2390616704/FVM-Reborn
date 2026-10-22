#macro GLIDER_DAMAGE_TRANSFER_CHANCE 0.7

function glider_enemy_is_valid(enemy, glider) {
	if (!instance_exists(enemy)) return false;
	if (enemy == glider) return false;
	if (!variable_instance_exists(enemy, "hp") || enemy.hp <= 0) return false;
	if (!variable_instance_exists(enemy, "state") || enemy.state == ENEMY_STATE.DEAD) return false;
	return true;
}

function glider_try_transfer_damage(glider, amount, damage_type) {
	if (!instance_exists(glider)) return false;
	if (glider.mouse_id != "glider_mouse") return false;
	if (amount <= 0) return false;
	if (variable_instance_exists(glider, "glider_transfer_damage") && glider.glider_transfer_damage) return false;
	if (variable_instance_exists(glider, "ghost_transfer_damage") && glider.ghost_transfer_damage) return false;
	if (variable_instance_exists(glider, "guardian_transfer_damage") && glider.guardian_transfer_damage) return false;
	if (random(1) >= GLIDER_DAMAGE_TRANSFER_CHANCE) return false;

	var _recipient = noone;
	var _best_dist = 1000000000;

	with (obj_enemy_parent) {
		if (!glider_enemy_is_valid(id, glider)) continue;
		if (grid_row != glider.grid_row) continue;
		if (target_type != "normal") continue;
		if (is_boss || giant_type) continue;
		if (mouse_id == "glider_mouse") continue;
		if (variable_instance_exists(id, "is_carried") && is_carried) continue;
		if (variable_instance_exists(id, "climb_stage") && climb_stage > 0) continue;
		if (variable_instance_exists(id, "glider_transfer_damage") && glider_transfer_damage) continue;

		var _dist = abs(x - glider.x);
		if (_dist < _best_dist) {
			_best_dist = _dist;
			_recipient = id;
		}
	}

	if (_recipient == noone) return false;

	_recipient.damage_amount = amount;
	_recipient.damage_type = damage_type;
	_recipient.glider_transfer_damage = true;
	with (_recipient) event_user(0);
	if (instance_exists(_recipient)) _recipient.glider_transfer_damage = false;

	return true;
}

function glider_try_swap(glider) {
	if (!instance_exists(glider)) return;

	var _row = glider.grid_row;
	var _is_row_front = true;
	var _rear_x = glider.x;

	with (obj_enemy_parent) {
		if (!glider_enemy_is_valid(id, glider)) continue;
		if (grid_row != _row) continue;
		if (x < glider.x) _is_row_front = false;
		if (x > _rear_x) _rear_x = x;
	}

	if (!_is_row_front) return;

	var _target = noone;
	var _target_x = -1000000;

	with (obj_enemy_parent) {
		if (!glider_enemy_is_valid(id, glider)) continue;
		if (grid_row == _row) continue;
		if (target_type != "normal") continue;
		if (is_boss || giant_type) continue;
		if (mouse_id == "glider_mouse") continue;
		if (variable_instance_exists(id, "is_carried") && is_carried) continue;
		if (variable_instance_exists(id, "climb_stage") && climb_stage > 0) continue;

		if (x > _target_x) {
			_target_x = x;
			_target = id;
		}
	}

	if (_target == noone) return;

	var _front_x = glider.x;
	var _front_y = glider.y;
	var _glider_x = _rear_x + global.grid_cell_size_x * 0.5;

	var _target_pos = get_grid_position_from_world(_front_x, _front_y);
	_target.x = _front_x;
	_target.y = _front_y;
	_target.grid_col = _target_pos.col;
	_target.grid_row = _target_pos.row;
	_target.target_plant = noone;

	glider.x = _glider_x;
	var _glider_pos = get_grid_position_from_world(glider.x, glider.y);
	glider.grid_col = _glider_pos.col;
	glider.grid_row = _glider_pos.row;
	glider.target_plant = noone;
}
