owner = noone;
beam_type = "general";
target = noone;
lock_frames = 0;
tick_timer = 0;
tick_index = 0;
intensity = 0;
visual_time = 0;
sparks = [];
depth = -500;
image_speed = 0;

beam_target_type = function() {
    if (beam_type == "air") return "air_only";
    return owner.general_target_type;
};

in_owner_range = function(t) {
    if (!instance_exists(t)) return false;
    return abs(t.grid_row - owner.grid_row) <= 3 && abs(t.grid_col - owner.grid_col) <= 3;
};

acquire_target = function() {
    var _ow = owner;
    var _tt = beam_target_type();
    var _gr = _ow.grid_row;
    var _gc = _ow.grid_col;
    var _self = id;
    var _beams = is_array(_ow.beam_list) ? _ow.beam_list : [];
    var best = noone;
    var best_hp = -1;
    var best_col = 99999;
    var best_rowdist = 99999;

    with (obj_enemy_parent) {
        if (hp <= 0) continue;
        if (abs(grid_row - _gr) > 3 || abs(grid_col - _gc) > 3) continue;
        if (!can_target_on(_tt, target_type)) continue;
        var _taken = false;
        for (var _bi = 0; _bi < array_length(_beams); _bi++) {
            var _b = _beams[_bi];
            if (_b == _self) continue;
            if (instance_exists(_b) && _b.target == id) { _taken = true; break; }
        }
        if (_taken) continue;
        var _rd = abs(grid_row - _gr);
        if (hp > best_hp ||
            (hp == best_hp && (grid_col < best_col ||
            (grid_col == best_col && _rd < best_rowdist)))) {
            best = id;
            best_hp = hp;
            best_col = grid_col;
            best_rowdist = _rd;
        }
    }

    if (beam_type == "general") {
        with (obj_obstacle) {
            if (!is_map_obstacle) continue;
            if (hp <= 0) continue;
            if (abs(grid_row - _gr) > 3 || abs(grid_col - _gc) > 3) continue;
            if (!can_target_on(_tt, target_type)) continue;
            var _taken2 = false;
            for (var _bi2 = 0; _bi2 < array_length(_beams); _bi2++) {
                var _b2 = _beams[_bi2];
                if (_b2 == _self) continue;
                if (instance_exists(_b2) && _b2.target == id) { _taken2 = true; break; }
            }
            if (_taken2) continue;
            var _rd2 = abs(grid_row - _gr);
            if (hp > best_hp ||
                (hp == best_hp && (grid_col < best_col ||
                (grid_col == best_col && _rd2 < best_rowdist)))) {
                best = id;
                best_hp = hp;
                best_col = grid_col;
                best_rowdist = _rd2;
            }
        }
    }
    return best;
};

apply_tick_damage = function() {
    if (!instance_exists(target)) return;
    var m = 0.3 + 0.7 * power(min(lock_frames / 300, 1), 1.5);
    var dmg = round(owner.atk * m);

    if (target.object_index == obj_obstacle) {
        dmg *= 3;
        target.hp -= dmg;
        if (target.hp <= 0) {
            var _r = target.grid_row;
            var _c = target.grid_col;
            if (_r >= 0 && _r < global.grid_rows && _c >= 0 && _c < global.grid_cols) {
                global.grid_terrains[_r][_c].type = (global.row_feature[_r] == "water") ? "water" : "normal";
            }
            instance_destroy(target);
            target = noone;
        }
    } else {
        with (target) {
            damage_amount = dmg;
            damage_type = "pierce";
            event_user(0);
        }
        if (!instance_exists(target)) target = noone;
    }
};
