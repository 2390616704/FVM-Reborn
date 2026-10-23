function enemy_throw_push_target(_thrower) {
    var _candidates = [];
    with (obj_enemy_parent) {
        if (id == _thrower) continue;
        if (hp <= 0 || state == ENEMY_STATE.DEAD) continue;
        if (state != ENEMY_STATE.NORMAL && state != ENEMY_STATE.ATTACK) continue;
        if (grid_col <= 6 || grid_col >= global.grid_cols) continue;
        if (target_type == "obstacle") continue;
        array_push(_candidates, id);
    }

    if (array_length(_candidates) == 0) return -1;

    var _target = _candidates[irandom(array_length(_candidates) - 1)];
    var _steps = irandom_range(1, 3);
    _target.x -= _steps * global.grid_cell_size_x;
    var _grid = get_grid_position_from_world(_target.x, _target.y);
    _target.grid_col = _grid.col;
    return _grid.col;
}

function enemy_throw_little_mouse(_thrower, _little_obj, _fallback_min, _fallback_max) {
    var _target_col = enemy_throw_push_target(_thrower);
    if (_target_col < 0) _target_col = irandom_range(_fallback_min, _fallback_max);

    var _inst = instance_create_depth(_thrower.x + 35, _thrower.y - 125, _thrower.depth - 1, _little_obj);
    _inst.target_col = _target_col;
    _inst.target_row = _thrower.grid_row;
    _inst.grid_row = _thrower.grid_row;

    var _target_pos = get_world_position_from_grid(_target_col, _thrower.grid_row);
    var _distance_x = _target_pos.x - _inst.x;
    var _flight_time = clamp(75 + (_distance_x / 1000) * 45, 75, 120);
    _inst.chspeed = _distance_x / _flight_time;
    _inst.cgravity = (2 * 600) / (_flight_time * _flight_time);
    _inst.cvspeed = (600 - 0.05 * _inst.cgravity * _flight_time * _flight_time) / _flight_time;
    return _inst;
}
