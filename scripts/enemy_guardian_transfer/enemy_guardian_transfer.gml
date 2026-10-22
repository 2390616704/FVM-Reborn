#macro ENEMY_GUARDIAN_LOW_HP 400
#macro ENEMY_GUARDIAN_CHANCE 0.5
#macro ENEMY_GUARDIAN_LINE_LIFE 18

function enemy_guardian_effective_max(_enemy) {
    return max(0, _enemy.maxhp) + max(0, _enemy.helmet_max_hp) + max(0, _enemy.shield_max_hp);
}

function enemy_guardian_effective_hp(_enemy) {
    return max(0, _enemy.hp) + max(0, _enemy.helmet_hp) + max(0, _enemy.shield_hp);
}

function enemy_guardian_build_type_cache() {
    if (variable_global_exists("enemy_guardian_object_types") && ds_exists(global.enemy_guardian_object_types, ds_type_map)) {
        if (ds_map_size(global.enemy_guardian_object_types) > 0) return;
        ds_map_destroy(global.enemy_guardian_object_types);
    }

    global.enemy_guardian_object_types = ds_map_create();
    if (!variable_global_exists("enemy_map")) return;
    if (!ds_exists(global.enemy_map, ds_type_map)) return;

    var _key = ds_map_find_first(global.enemy_map);
    while (!is_undefined(_key)) {
        var _data = global.enemy_map[? _key];
        if (is_struct(_data) && variable_struct_exists(_data, "_obj")) {
            if (!ds_map_exists(global.enemy_guardian_object_types, _data._obj)) {
                ds_map_add(global.enemy_guardian_object_types, _data._obj, true);
            }
        }
        _key = ds_map_find_next(global.enemy_map, _key);
    }
}

function enemy_guardian_is_registered(_enemy) {
    if (!instance_exists(_enemy)) return false;
    if (variable_instance_exists(_enemy, "guardian_eligible") && _enemy.guardian_eligible) return true;
    enemy_guardian_build_type_cache();
    if (!variable_global_exists("enemy_guardian_object_types")) return false;
    if (!ds_exists(global.enemy_guardian_object_types, ds_type_map)) return false;
    return ds_map_exists(global.enemy_guardian_object_types, _enemy.object_index);
}

function enemy_guardian_is_valid(_enemy, _exclude) {
    if (_enemy == noone || !instance_exists(_enemy)) return false;
    if (_enemy == _exclude) return false;
    if (!variable_instance_exists(_enemy, "hp") || _enemy.hp <= 0) return false;
    if (!variable_instance_exists(_enemy, "state")) return false;
    if (_enemy.state == ENEMY_STATE.DEAD) return false;
    if (!variable_instance_exists(_enemy, "is_boss") || _enemy.is_boss) return false;
    return enemy_guardian_is_registered(_enemy);
}

function enemy_guardian_pick(_source) {
    var _best = noone;
    var _best_max = -1;
    var _best_hp = -1;
    var _best_dist = 1000000000;

    with (obj_enemy_parent) {
        if (!enemy_guardian_is_valid(id, _source)) continue;

        var _max = enemy_guardian_effective_max(id);
        var _hp = enemy_guardian_effective_hp(id);
        var _dist = point_distance(x, y, _source.x, _source.y);
        var _better = false;

        if (_best == noone) {
            _better = true;
        }
        else if (_max > _best_max) {
            _better = true;
        }
        else if (_max == _best_max && _hp > _best_hp) {
            _better = true;
        }
        else if (_max == _best_max && _hp == _best_hp && _dist < _best_dist) {
            _better = true;
        }
        else if (_max == _best_max && _hp == _best_hp && _dist == _best_dist && id < _best) {
            _better = true;
        }

        if (_better) {
            _best = id;
            _best_max = _max;
            _best_hp = _hp;
            _best_dist = _dist;
        }
    }

    return _best;
}

function enemy_guardian_reset() {
    global.guardian_enemy = noone;
    global.guardian_transfer_lines = [];
}

function enemy_guardian_add_line(_x1, _y1, _x2, _y2) {
    if (!variable_global_exists("guardian_transfer_lines")) global.guardian_transfer_lines = [];
    array_push(global.guardian_transfer_lines, { x1: _x1, y1: _y1, x2: _x2, y2: _y2, life: ENEMY_GUARDIAN_LINE_LIFE });
}

function enemy_guardian_update_lines() {
    if (!variable_global_exists("guardian_transfer_lines")) return;

    for (var i = array_length(global.guardian_transfer_lines) - 1; i >= 0; i--) {
        var _line = global.guardian_transfer_lines[i];
        _line.life -= 1;
        if (_line.life <= 0) array_delete(global.guardian_transfer_lines, i, 1);
    }
}

function enemy_guardian_try_transfer(_target, _amount, _type) {
    if (_amount <= 0) return false;
    if (variable_global_exists("laboretory_room") && global.laboretory_room) return false;
    if (!instance_exists(_target)) return false;
    if (!enemy_guardian_is_registered(_target)) return false;
    if (_target.is_boss) return false;
    if (_target.hp <= 0) return false;
    if (_target.state == ENEMY_STATE.DEAD) return false;
    if (_target.mouse_id == "ghost_mouse") return false;
    if (variable_instance_exists(_target, "ghost_transfer_damage") && _target.ghost_transfer_damage) return false;
    if (variable_instance_exists(_target, "guardian_transfer_damage") && _target.guardian_transfer_damage) return false;
    if (enemy_guardian_effective_hp(_target) > ENEMY_GUARDIAN_LOW_HP) return false;

    if (!variable_global_exists("guardian_enemy")) global.guardian_enemy = noone;
    if (_target == global.guardian_enemy) return false;
    if (random(1) >= ENEMY_GUARDIAN_CHANCE) return false;

    var _guardian = global.guardian_enemy;
    if (!enemy_guardian_is_valid(_guardian, _target)) {
        _guardian = enemy_guardian_pick(_target);
        if (_guardian == noone) {
            global.guardian_enemy = noone;
            return false;
        }
        global.guardian_enemy = _guardian;
    }

    var _tx = _target.x;
    var _ty = _target.y;
    var _gx = _guardian.x;
    var _gy = _guardian.y;

    _guardian.guardian_transfer_damage = true;
    _guardian.damage_amount = _amount;
    _guardian.damage_type = _type;
    with (_guardian) event_user(0);
    if (instance_exists(_guardian)) _guardian.guardian_transfer_damage = false;

    enemy_guardian_add_line(_tx, _ty - 40, _gx, _gy - 40);
    return true;
}

function enemy_guardian_draw_marker(_enemy) {
    if (!variable_global_exists("guardian_enemy")) return;
    if (global.guardian_enemy != _enemy) return;
    if (!enemy_guardian_is_valid(_enemy, noone)) return;
    if (variable_global_exists("is_paused") && global.is_paused) return;

    var _x = _enemy.x;
    var _y = _enemy.y - 95;

    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_circle(_x, _y, 13, false);
    draw_set_color(c_aqua);
    draw_circle(_x, _y, 12, true);
    draw_set_alpha(1);
    draw_set_font(font_yuan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_text_transformed(_x + 1, _y + 1, "守", 0.65, 0.65, 0);
    draw_set_color(c_white);
    draw_text_transformed(_x, _y, "守", 0.65, 0.65, 0);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

function enemy_guardian_draw_lines() {
    if (!variable_global_exists("guardian_transfer_lines")) return;
    if (array_length(global.guardian_transfer_lines) == 0) return;

    draw_set_color(c_aqua);
    for (var i = 0; i < array_length(global.guardian_transfer_lines); i++) {
        var _line = global.guardian_transfer_lines[i];
        draw_set_alpha(clamp(_line.life / ENEMY_GUARDIAN_LINE_LIFE, 0, 1));
        draw_line_width(_line.x1, _line.y1, _line.x2, _line.y2, 2);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}
