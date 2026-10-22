#macro FLOUR_SACK_MAX_ORBIT 100
#macro FLOUR_SACK_CHARGE_STEPS 60
#macro FLOUR_SACK_ORBIT_SPEED 1.2
#macro FLOUR_SACK_ORBIT_Y_OFFSET 40
#macro FLOUR_SACK_ORBIT_PERSPECTIVE 0.7
#macro FLOUR_SACK_FLIGHT_STEPS 40
#macro FLOUR_SACK_COLLAPSE_STEPS 26

function flour_sack_eligible_objects() {
    static _objects = [
        obj_xiaolongbao_bullet,
        obj_icelongbao_bullet,
        obj_waterpipe_bullet,
        obj_icegun_bullet,
        obj_mightygun_bullet,
        obj_catgun_bullet,
        obj_coffeecup_bullet,
        obj_sausage_bullet,
        obj_triplewinerack_bullet,
        obj_hotdogcannon_bullet,
        obj_nutfrier_bullet,
        obj_coalstarfish_bullet
    ];
    return _objects;
}

function flour_sack_bullet_in_strip(_bullet, _flour) {
    if (abs(_bullet.x - _flour.x) > global.grid_cell_size_x * 0.5) {
        return false;
    }
    return _bullet.row == _flour.grid_row;
}

function flour_sack_capture_bullet(_flour, _bullet) {
    _bullet.flour_sack_captured = true;
    _bullet.active = false;
    _bullet.image_speed = 0;
    _bullet.image_alpha = 0.25;

    var _index = array_length(_flour.orbit_visuals);
    array_push(_flour.orbit_visuals, _bullet);
    var _ring = _index mod 3;
    var _slot = floor(_index / 3);
    var _ring_radii = [1.3, 1.7, 2.1];
    array_push(_flour.orbit_angles, (_slot * 137.508) mod 360);
    array_push(_flour.orbit_radii, global.grid_cell_size_x * _ring_radii[_ring]);

    if (variable_instance_exists(_bullet, "damage")) {
        _flour.orbit_damage += _bullet.damage;
    }

    var _obj = _bullet.object_index;
    if (_obj == obj_catgun_bullet) {
        _flour.orbit_has_scare = true;
    }
    if ((_obj == obj_icelongbao_bullet || _obj == obj_icegun_bullet || _obj == obj_hotdogcannon_bullet)
        && (!variable_instance_exists(_bullet, "burnt") || _bullet.burnt == 0)) {
        _flour.orbit_has_ice = true;
    }
}

function flour_sack_find_receiver(_bullet) {
    var _best = noone;
    var _best_count = -1;
    var _best_dist = 1000000;
    with (obj_flour_sack) {
        if (state != CARD_STATE.IDLE) {
            continue;
        }
        var _count = array_length(orbit_visuals);
        if (_count >= FLOUR_SACK_MAX_ORBIT) {
            continue;
        }
        var _dist = point_distance(x, y, _bullet.x, _bullet.y);
        if (_count > _best_count || (_count == _best_count && _dist < _best_dist)) {
            _best = id;
            _best_count = _count;
            _best_dist = _dist;
        }
    }
    return _best;
}

function flour_sack_capture_step(_flour) {
    var _objects = flour_sack_eligible_objects();
    for (var i = 0; i < array_length(_objects); i++) {
        var _obj = _objects[i];
        with (_obj) {
            if ((!variable_instance_exists(id, "flour_sack_captured") || !id.flour_sack_captured)
                && flour_sack_bullet_in_strip(id, _flour)) {
                var _receiver = flour_sack_find_receiver(id);
                if (_receiver != noone) {
                    flour_sack_capture_bullet(_receiver, id);
                }
            }
        }
    }
}

function flour_sack_prune_orbit(_flour) {
    var _bullets = _flour.orbit_visuals;
    var _angles = _flour.orbit_angles;
    var _radii = _flour.orbit_radii;
    var _new_bullets = [];
    var _new_angles = [];
    var _new_radii = [];
    for (var i = 0; i < array_length(_bullets); i++) {
        if (!instance_exists(_bullets[i])) {
            continue;
        }
        array_push(_new_bullets, _bullets[i]);
        array_push(_new_angles, _angles[i]);
        array_push(_new_radii, _radii[i]);
    }
    _flour.orbit_visuals = _new_bullets;
    _flour.orbit_angles = _new_angles;
    _flour.orbit_radii = _new_radii;
    if (array_length(_new_bullets) == 0) {
        _flour.orbit_damage = 0;
        _flour.orbit_has_ice = false;
        _flour.orbit_has_scare = false;
    }
}

function flour_sack_update_orbit(_flour) {
    flour_sack_prune_orbit(_flour);
    var _cx = _flour.x;
    var _cy = _flour.y - FLOUR_SACK_ORBIT_Y_OFFSET;
    var _count = array_length(_flour.orbit_visuals);
    for (var i = 0; i < _count; i++) {
        var _visual = _flour.orbit_visuals[i];
        _flour.orbit_angles[i] += FLOUR_SACK_ORBIT_SPEED;
        var _angle = _flour.orbit_angles[i];
        var _radius = _flour.orbit_radii[i];
        _visual.x = _cx + lengthdir_x(_radius, _angle);
        _visual.y = _cy + lengthdir_y(_radius, _angle) * FLOUR_SACK_ORBIT_PERSPECTIVE;
    }
}

function flour_sack_clear_orbit(_flour) {
    var _count = array_length(_flour.orbit_visuals);
    for (var i = 0; i < _count; i++) {
        if (instance_exists(_flour.orbit_visuals[i])) {
            _flour.orbit_visuals[i].active = true;
            instance_destroy(_flour.orbit_visuals[i]);
        }
    }
    _flour.orbit_visuals = [];
    _flour.orbit_angles = [];
    _flour.orbit_radii = [];
    _flour.orbit_damage = 0;
    _flour.orbit_has_ice = false;
    _flour.orbit_has_scare = false;
}

function flour_sack_try_jump(_flour) {
    if (!instance_exists(_flour)) {
        return false;
    }
    if (_flour.payload_active || _flour.state != CARD_STATE.IDLE) {
        return false;
    }
    var _has_target = false;
    with (obj_enemy_parent) {
        if (hp > 0
            && grid_row == _flour.grid_row
            && grid_col >= _flour.grid_col - _flour.range
            && grid_col <= _flour.grid_col + _flour.range
            && can_target_on(_flour.target_type, target_type)) {
            _flour.first_target_x = x;
            _flour.first_target_y = y;
            _has_target = true;
            break;
        }
    }
    if (!_has_target) {
        return false;
    }
    if (array_length(_flour.orbit_visuals) > 0) {
        flour_sack_clear_orbit(_flour);
    }
    _flour.state = CARD_STATE.ATTACK;
    _flour.attack_timer = 0;
    return true;
}

function flour_sack_find_target(_flour) {
    var _best = undefined;
    var _best_col = 1000000;
    var _best_row_dist = 1000000;
    var _best_row = 1000000;
    with (obj_enemy_parent) {
        if (hp > 0
            && grid_col >= 0 && grid_col < global.grid_cols
            && grid_row >= 0 && grid_row < global.grid_rows
            && grid_col > _flour.grid_col
            && can_target_on(_flour.target_type, target_type)) {
            var _row_dist = abs(grid_row - _flour.grid_row);
            if (grid_col < _best_col
                || (grid_col == _best_col && _row_dist < _best_row_dist)
                || (grid_col == _best_col && _row_dist == _best_row_dist && grid_row < _best_row)) {
                _best_col = grid_col;
                _best_row_dist = _row_dist;
                _best_row = grid_row;
                _best = { col: grid_col, row: grid_row };
            }
        }
    }
    if (!is_undefined(_best)) {
        var _pos = get_world_position_from_grid(_best.col, _best.row);
        _best.x = _pos.x;
        _best.y = _pos.y;
    }
    return _best;
}

function flour_sack_try_launch(_flour) {
    flour_sack_prune_orbit(_flour);
    if (array_length(_flour.orbit_visuals) <= 0) {
        return false;
    }
    var _target = flour_sack_find_target(_flour);
    if (is_undefined(_target)) {
        return false;
    }

    var _cx = _flour.x;
    var _cy = _flour.y - FLOUR_SACK_ORBIT_Y_OFFSET;
    var _payload = {
        flour_id: _flour.id,
        target_col: _target.col,
        target_row: _target.row,
        target_x: _target.x,
        target_y: _target.y,
        visuals: _flour.orbit_visuals,
        offsets_x: [],
        offsets_y: [],
        scales_x: [],
        scales_y: [],
        damage: _flour.orbit_damage,
        has_ice: _flour.orbit_has_ice,
        has_scare: _flour.orbit_has_scare,
        timer: 0,
        flight: FLOUR_SACK_FLIGHT_STEPS,
        collapse: FLOUR_SACK_COLLAPSE_STEPS,
        center_x: _cx,
        center_y: _cy
    };

    for (var i = 0; i < array_length(_payload.visuals); i++) {
        var _visual = _payload.visuals[i];
        array_push(_payload.offsets_x, _visual.x - _cx);
        array_push(_payload.offsets_y, _visual.y - _cy);
        array_push(_payload.scales_x, _visual.image_xscale);
        array_push(_payload.scales_y, _visual.image_yscale);
    }

    if (!variable_global_exists("flour_sack_payloads")) {
        global.flour_sack_payloads = [];
    }
    array_push(global.flour_sack_payloads, _payload);

    _flour.payload_active = true;
    _flour.orbit_visuals = [];
    _flour.orbit_angles = [];
    _flour.orbit_radii = [];
    _flour.orbit_damage = 0;
    _flour.orbit_has_ice = false;
    _flour.orbit_has_scare = false;
    return true;
}

function flour_sack_apply_impact(_p) {
    var _col = _p.target_col;
    var _row = _p.target_row;
    var _damage = _p.damage;
    var _has_scare = _p.has_scare;
    var _has_ice = _p.has_ice;
    with (obj_enemy_parent) {
        if (hp > 0 && abs(grid_col - _col) <= 1 && abs(grid_row - _row) <= 1) {
            if (_damage > 0) {
                damage_amount = _damage;
                damage_type = "normal";
                event_user(0);
            }

            if (_has_scare) {
                scare_timer = 30;
                left_move_flashs = 30;
                if (global.grid_rows > 1) {
                    if (grid_row == 0) {
                        if (global.row_feature[1] == global.row_feature[0]) {
                            y_move = global.grid_cell_size_y / left_move_flashs;
                            grid_row += 1;
                        }
                    }
                    else if (grid_row == global.grid_rows - 1) {
                        if (global.row_feature[global.grid_rows - 2] == global.row_feature[global.grid_rows - 1]) {
                            y_move = -global.grid_cell_size_y / left_move_flashs;
                            grid_row -= 1;
                        }
                    }
                    else {
                        var _im = irandom_range(1, 100);
                        var _up_water = global.row_feature[grid_row - 1] != global.row_feature[grid_row];
                        var _down_water = global.row_feature[grid_row + 1] != global.row_feature[grid_row];
                        if (_down_water) {
                            _im = 25;
                        }
                        if (_up_water) {
                            _im = 75;
                        }
                        if (!(_up_water && _down_water)) {
                            if (_im > 50) {
                                y_move = global.grid_cell_size_y / left_move_flashs;
                                grid_row += 1;
                            }
                            else {
                                y_move = -global.grid_cell_size_y / left_move_flashs;
                                grid_row -= 1;
                            }
                        }
                    }
                }
            }

            if (_has_ice && ice_timer < 600) {
                ice_timer = 600;
            }
        }
    }
}

function flour_sack_payload_update_all() {
    if (!variable_global_exists("flour_sack_payloads")) {
        return;
    }
    var _list = global.flour_sack_payloads;
    for (var i = array_length(_list) - 1; i >= 0; i--) {
        var _p = _list[i];
        var _t = _p.timer;
        var _flight = _p.flight;
        var _collapse = _p.collapse;
        var _visual = noone;
        var _progress = 0;
        var _raw = 0;
        var _scale_mul = 1;

        if (_t < _flight) {
            _raw = (_t + 1) / _flight;
            _progress = 1 - (1 - _raw) * (1 - _raw);
            var _ax = lerp(_p.center_x, _p.target_x, _progress);
            var _ay = lerp(_p.center_y, _p.target_y, _progress);
            for (var j = 0; j < array_length(_p.visuals); j++) {
                _visual = _p.visuals[j];
                if (!instance_exists(_visual)) {
                    continue;
                }
                _visual.x = _ax + _p.offsets_x[j];
                _visual.y = _ay + _p.offsets_y[j];
                _visual.image_alpha = lerp(0.25, 1, min(1, _raw * 2));
            }
        }
        else if (_t < _flight + _collapse) {
            _raw = (_t - _flight + 1) / _collapse;
            _progress = _raw * _raw;
            _scale_mul = 1 - 0.9 * _progress;
            for (var j = 0; j < array_length(_p.visuals); j++) {
                _visual = _p.visuals[j];
                if (!instance_exists(_visual)) {
                    continue;
                }
                _visual.x = lerp(_p.target_x + _p.offsets_x[j], _p.target_x, _progress);
                _visual.y = lerp(_p.target_y + _p.offsets_y[j], _p.target_y, _progress);
                _visual.image_xscale = _p.scales_x[j] * _scale_mul;
                _visual.image_yscale = _p.scales_y[j] * _scale_mul;
                _visual.image_alpha = 1;
            }
        }
        else {
            flour_sack_apply_impact(_p);
            for (var j = 0; j < array_length(_p.visuals); j++) {
                if (instance_exists(_p.visuals[j])) {
                    _p.visuals[j].active = true;
                    instance_destroy(_p.visuals[j]);
                }
            }
            if (instance_exists(_p.flour_id)) {
                _p.flour_id.payload_active = false;
            }
            array_delete(_list, i, 1);
            continue;
        }

        _p.timer++;
    }
    global.flour_sack_payloads = _list;
}

function flour_sack_clear_all_payloads() {
    if (!variable_global_exists("flour_sack_payloads")) {
        global.flour_sack_payloads = [];
        return;
    }
    var _list = global.flour_sack_payloads;
    for (var i = 0; i < array_length(_list); i++) {
        var _p = _list[i];
        for (var j = 0; j < array_length(_p.visuals); j++) {
            if (instance_exists(_p.visuals[j])) {
                _p.visuals[j].active = true;
                instance_destroy(_p.visuals[j]);
            }
        }
        if (instance_exists(_p.flour_id)) {
            _p.flour_id.payload_active = false;
        }
    }
    global.flour_sack_payloads = [];
}
