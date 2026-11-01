function random_challenge_clone(_value) {
    if (is_undefined(_value)) return undefined;
    return json_parse(json_stringify(_value));
}

function random_challenge_state_is_populated(_state) {
    if (!is_struct(_state)) return false;
    if (!variable_struct_exists(_state, "map_id")) return false;
    if (!variable_struct_exists(_state, "level_id")) return false;
    if (!variable_struct_exists(_state, "file_path")) return false;
    if (!variable_struct_exists(_state, "candidates")) return false;
    if (!variable_struct_exists(_state, "boss")) return false;
    if (!variable_struct_exists(_state, "assignments")) return false;
    return true;
}

function random_challenge_read_level_file(_relative_path) {
    if (!is_string(_relative_path) || _relative_path == "") return undefined;
    var _buffer = buffer_load("level_data/" + _relative_path);
    if (!buffer_exists(_buffer)) return undefined;
    var _json_string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    try {
        var _parsed = json_parse(_json_string);
        if (is_struct(_parsed)) return _parsed;
    }
    catch (e) {
        return undefined;
    }
    return undefined;
}

function random_challenge_find_level_data(_map_id, _level_id) {
    if (!ds_map_exists(global.maps_map, _map_id)) return undefined;
    var _map = ds_map_find_value(global.maps_map, _map_id);
    if (!is_struct(_map)) return undefined;
    var _levels = struct_get(_map, "levels_data");
    if (!is_array(_levels)) return undefined;
    for (var i = 0; i < array_length(_levels); i++) {
        if (_levels[i].id == _level_id) return _levels[i];
    }
    return undefined;
}

function random_challenge_map_name(_map_id) {
    if (!ds_map_exists(global.maps_map, _map_id)) return _map_id;
    var _map = ds_map_find_value(global.maps_map, _map_id);
    if (!is_struct(_map)) return _map_id;
    return struct_get(_map, "map_name");
}

function random_challenge_has_water(_level_file) {
    if (!is_struct(_level_file) || !variable_struct_exists(_level_file, "map")) return false;
    var _map = _level_file.map;
    if (!is_array(_map)) return false;
    for (var r = 0; r < array_length(_map); r++) {
        var _row = _map[r];
        if (!is_array(_row) || array_length(_row) <= 0) continue;
        if (_row[0].type == "water") return true;
    }
    return false;
}

function random_challenge_slot_count(_level_file) {
    if (!is_struct(_level_file) || !variable_struct_exists(_level_file, "waves")) return 0;
    var _waves = _level_file.waves;
    if (!is_array(_waves)) return 0;
    var _count = 0;
    for (var i = 0; i < array_length(_waves); i++) {
        var _subwaves = _waves[i].subwaves;
        if (!is_array(_subwaves)) continue;
        for (var j = 0; j < array_length(_subwaves); j++) {
            var _enemy_list = _subwaves[j].enemy_list;
            if (is_array(_enemy_list)) _count += array_length(_enemy_list);
        }
    }
    return _count;
}

function random_challenge_collect_assignments(_level_file) {
    var _out = [];
    var _waves = _level_file.waves;
    for (var i = 0; i < array_length(_waves); i++) {
        var _subwaves = _waves[i].subwaves;
        if (!is_array(_subwaves)) continue;
        for (var j = 0; j < array_length(_subwaves); j++) {
            var _enemy_list = _subwaves[j].enemy_list;
            if (!is_array(_enemy_list)) continue;
            for (var k = 0; k < array_length(_enemy_list); k++) {
                array_push(_out, _enemy_list[k].type);
            }
        }
    }
    return _out;
}

function random_challenge_apply_assignments(_level_file, _assignments) {
    if (!is_array(_assignments)) return false;
    if (random_challenge_slot_count(_level_file) != array_length(_assignments)) return false;
    for (var a = 0; a < array_length(_assignments); a++) {
        if (!ds_map_exists(global.enemy_map, _assignments[a])) return false;
    }
    var _index = 0;
    var _waves = _level_file.waves;
    for (var i = 0; i < array_length(_waves); i++) {
        var _subwaves = _waves[i].subwaves;
        if (!is_array(_subwaves)) continue;
        for (var j = 0; j < array_length(_subwaves); j++) {
            var _enemy_list = _subwaves[j].enemy_list;
            if (!is_array(_enemy_list)) continue;
            for (var k = 0; k < array_length(_enemy_list); k++) {
                _enemy_list[k].type = _assignments[_index];
                _index++;
            }
        }
    }
    return true;
}

function random_challenge_force_boss(_level_file, _boss_id) {
    if (!is_struct(_level_file) || !variable_struct_exists(_level_file, "waves")) return false;
    if (!ds_map_exists(global.enemy_map, _boss_id)) return false;
    var _waves = _level_file.waves;
    if (!is_array(_waves) || array_length(_waves) <= 0) return false;
    var _last = array_length(_waves) - 1;
    for (var i = 0; i < array_length(_waves); i++) {
        var _wave = _waves[i];
        _wave.boss2 = "";
        _wave.boss_2_hp_modify = 1.0;
        if (i == _last) {
            _wave.boss_wave = true;
            _wave.boss = _boss_id;
            _wave.boss_1_hp_modify = 1.0;
        }
        else {
            _wave.boss_wave = false;
            _wave.boss = "";
        }
    }
    _level_file.total_waves = array_length(_waves);
    _level_file.boss_wave = _last;
    _level_file.boss = _boss_id;
    return true;
}

function random_challenge_assign_random(_level_file, _candidates) {
    if (!is_array(_candidates) || array_length(_candidates) <= 0) return [];
    var _out = [];
    var _waves = _level_file.waves;
    for (var i = 0; i < array_length(_waves); i++) {
        var _subwaves = _waves[i].subwaves;
        if (!is_array(_subwaves)) continue;
        for (var j = 0; j < array_length(_subwaves); j++) {
            var _enemy_list = _subwaves[j].enemy_list;
            if (!is_array(_enemy_list)) continue;
            for (var k = 0; k < array_length(_enemy_list); k++) {
                var _type = _candidates[irandom(array_length(_candidates) - 1)];
                _enemy_list[k].type = _type;
                array_push(_out, _type);
            }
        }
    }
    return _out;
}

function random_challenge_regular_enemy_pool(_has_water) {
    var _out = [];
    var _ids = ds_map_keys_to_array(global.enemy_map);
    for (var i = 0; i < array_length(_ids); i++) {
        var _id = _ids[i];
        if (ds_map_exists(global.boss_list, _id)) continue;
        if (_id == "machine_shark_2") continue;
        if (_id == "assault_mouse" || _id == "bat_mouse" || _id == "minion_mouse") continue;
        var _data = ds_map_find_value(global.enemy_map, _id);
        if (!is_struct(_data) || !variable_struct_exists(_data, "feature")) continue;
        if (!_has_water && _data.feature == "water") continue;
        array_push(_out, _id);
    }
    return _out;
}

function random_challenge_pick_candidates(_has_water) {
    var _pool = random_challenge_regular_enemy_pool(_has_water);
    shuffle_array(_pool);
    var _out = [];
    var _amount = min(15, array_length(_pool));
    for (var i = 0; i < _amount; i++) array_push(_out, _pool[i]);
    return _out;
}

function random_challenge_replace_water_candidates(_candidates) {
    var _pool = random_challenge_regular_enemy_pool(false);
    shuffle_array(_pool);
    var _used = {};
    for (var i = 0; i < array_length(_candidates); i++) {
        var _data = ds_map_find_value(global.enemy_map, _candidates[i]);
        if (is_struct(_data) && _data.feature != "water") _used[$ _candidates[i]] = true;
    }
    var _pool_index = 0;
    for (var i = 0; i < array_length(_candidates); i++) {
        var _data = ds_map_find_value(global.enemy_map, _candidates[i]);
        if (!is_struct(_data) || _data.feature != "water") continue;
        while (_pool_index < array_length(_pool) && variable_struct_exists(_used, _pool[_pool_index])) _pool_index++;
        if (_pool_index >= array_length(_pool)) break;
        _candidates[i] = _pool[_pool_index];
        _used[$ _pool[_pool_index]] = true;
        _pool_index++;
    }
    return _candidates;
}

function random_challenge_pick_boss() {
    var _pool = ds_map_keys_to_array(global.boss_list);
    if (array_length(_pool) <= 0) return "";
    shuffle_array(_pool);
    return _pool[0];
}

function random_challenge_build_map_pool() {
    var _out = [];
    var _map_ids = ds_map_keys_to_array(global.maps_map);
    for (var i = 0; i < array_length(_map_ids); i++) {
        var _map_id = _map_ids[i];
        if (_map_id == "tower_cake") continue;
        if (!ds_map_exists(global.maps_map, _map_id)) continue;
        var _map = ds_map_find_value(global.maps_map, _map_id);
        if (!is_struct(_map)) continue;
        var _levels = struct_get(_map, "levels_data");
        if (!is_array(_levels)) continue;
        for (var j = 0; j < array_length(_levels); j++) {
            var _level = _levels[j];
            if (!is_struct(_level)) continue;
            if (_level.id == "tower_cake" || _level.id == "camp_shop") continue;
            if (!variable_struct_exists(_level, "level_file") || _level.level_file == "") continue;
            var _path = _level.level_file;
            if (global.difficulty >= 2 && variable_struct_exists(_level, "hard_level_file") && _level.hard_level_file != "") {
                _path = _level.hard_level_file;
            }
            array_push(_out, {
                map_id: _map_id,
                map_name: struct_get(_map, "map_name"),
                level_data: _level,
                file_path: _path
            });
        }
    }
    return _out;
}

function random_challenge_pick_template() {
    var _pool = random_challenge_build_map_pool();
    shuffle_array(_pool);
    for (var i = 0; i < array_length(_pool); i++) {
        var _entry = _pool[i];
        var _level_file = random_challenge_read_level_file(_entry.file_path);
        if (!is_struct(_level_file)) continue;
        if (random_challenge_slot_count(_level_file) <= 0) continue;
        return { entry: _entry, level_file: _level_file };
    }
    return undefined;
}

function random_challenge_build_state(_entry, _level_file, _candidates, _boss) {
    return {
        version: 1,
        map_id: _entry.map_id,
        map_name: _entry.map_name,
        level_id: _entry.level_data.id,
        level_name: _entry.level_data.name,
        file_path: _entry.file_path,
        candidates: _candidates,
        boss: _boss,
        assignments: random_challenge_collect_assignments(_level_file)
    };
}

function random_challenge_set_globals(_state, _level_data, _level_file) {
    global.map_id = _state.map_id;
    global.map_name = _state.map_name;
    global.level_id = _state.level_id;
    global.level_name = _state.level_name;
    global.level_data = _level_data;
    global.level_file = _level_file;
}

function random_challenge_apply_state(_state) {
    if (!random_challenge_state_is_populated(_state)) return false;
    var _level_data = random_challenge_find_level_data(_state.map_id, _state.level_id);
    if (!is_struct(_level_data)) return false;
    var _level_file = random_challenge_read_level_file(_state.file_path);
    if (!is_struct(_level_file)) return false;
    if (!is_array(_state.candidates) || array_length(_state.candidates) <= 0) return false;
    for (var i = 0; i < array_length(_state.candidates); i++) {
        if (!ds_map_exists(global.enemy_map, _state.candidates[i])) return false;
    }
    if (!ds_map_exists(global.enemy_map, _state.boss)) return false;
    if (!is_array(_state.assignments)) return false;
    if (random_challenge_slot_count(_level_file) != array_length(_state.assignments)) return false;
    if (!random_challenge_apply_assignments(_level_file, _state.assignments)) return false;
    if (!random_challenge_force_boss(_level_file, _state.boss)) return false;
    random_challenge_set_globals(_state, _level_data, _level_file);
    return true;
}

function random_challenge_persist_current(_state) {
    global.save_data.random_challenge.current = random_challenge_clone(_state);
    save_file(global.save_slot);
}

function random_challenge_generate_new() {
    var _picked = random_challenge_pick_template();
    if (is_undefined(_picked)) return false;
    var _level_file = _picked.level_file;
    var _entry = _picked.entry;
    var _has_water = random_challenge_has_water(_level_file);
    var _candidates = random_challenge_pick_candidates(_has_water);
    var _boss = random_challenge_pick_boss();
    if (array_length(_candidates) <= 0 || _boss == "") return false;
    random_challenge_assign_random(_level_file, _candidates);
    if (!random_challenge_force_boss(_level_file, _boss)) return false;
    var _state = random_challenge_build_state(_entry, _level_file, _candidates, _boss);
    random_challenge_set_globals(_state, _entry.level_data, _level_file);
    random_challenge_persist_current(_state);
    return true;
}

function random_challenge_enter() {
    var _current = global.save_data.random_challenge.current;
    if (random_challenge_state_is_populated(_current)) {
        if (random_challenge_apply_state(_current)) {
            global.random_challenge_active = true;
            global.random_challenge_snapshot = "";
            return true;
        }
        show_notice("随机挑战存档已失效，已重新生成", 60);
    }
    if (random_challenge_generate_new()) {
        global.random_challenge_active = true;
        global.random_challenge_snapshot = "";
        return true;
    }
    show_notice("没有可用的随机挑战关卡", 60);
    return false;
}

function random_challenge_refresh_enemies() {
    if (!global.random_challenge_active) return false;
    var _state = global.save_data.random_challenge.current;
    if (!random_challenge_state_is_populated(_state)) return false;
    if (!is_array(_state.candidates)) return false;
    var _has_water = random_challenge_has_water(global.level_file);
    var _candidates = random_challenge_pick_candidates(_has_water);
    if (array_length(_candidates) <= 0) return false;
    _state.assignments = random_challenge_assign_random(global.level_file, _candidates);
    if (!random_challenge_force_boss(global.level_file, _state.boss)) return false;
    _state.candidates = _candidates;
    random_challenge_persist_current(_state);
    return true;
}

function random_challenge_refresh_boss() {
    if (!global.random_challenge_active) return false;
    var _state = global.save_data.random_challenge.current;
    if (!random_challenge_state_is_populated(_state)) return false;
    var _boss = random_challenge_pick_boss();
    if (_boss == "") return false;
    if (!random_challenge_force_boss(global.level_file, _boss)) return false;
    _state.boss = _boss;
    random_challenge_persist_current(_state);
    return true;
}

function random_challenge_refresh_map() {
    if (!global.random_challenge_active) return false;
    var _state = global.save_data.random_challenge.current;
    if (!random_challenge_state_is_populated(_state)) return false;
    if (!is_array(_state.candidates)) return false;
    var _picked = random_challenge_pick_template();
    if (is_undefined(_picked)) return false;
    var _level_file = _picked.level_file;
    var _entry = _picked.entry;
    var _candidates = _state.candidates;
    if (!random_challenge_has_water(_level_file)) {
        _candidates = random_challenge_replace_water_candidates(_candidates);
    }
    var _assignments = random_challenge_assign_random(_level_file, _candidates);
    if (!random_challenge_force_boss(_level_file, _state.boss)) return false;
    var _new_state = random_challenge_build_state(_entry, _level_file, _candidates, _state.boss);
    _new_state.assignments = _assignments;
    random_challenge_set_globals(_new_state, _entry.level_data, _level_file);
    random_challenge_persist_current(_new_state);
    return true;
}

function random_challenge_refresh_card_levels() {
    if (!global.random_challenge_active) return false;
    var _cards = global.save_data.unlocked_cards;
    if (!is_array(_cards) || array_length(_cards) <= 0) return false;
    for (var i = 0; i < array_length(_cards); i++) {
        var _card = _cards[i];
        if (!is_struct(_card)) continue;
        var _max_level = 0;
        if (variable_struct_exists(_card, "max_level")) _max_level = _card.max_level;
        if (!is_real(_max_level) || _max_level < 0) _max_level = 0;
        _card.level = irandom(floor(_max_level));
    }
    save_file(global.save_slot);
    return true;
}

function random_challenge_save_template() {
    var _state = global.save_data.random_challenge.current;
    if (!random_challenge_state_is_populated(_state)) return false;
    global.save_data.random_challenge.template = random_challenge_clone(_state);
    save_file(global.save_slot);
    return true;
}

function random_challenge_load_template() {
    var _template = global.save_data.random_challenge.template;
    if (!random_challenge_state_is_populated(_template)) return false;
    if (!random_challenge_apply_state(_template)) return false;
    global.random_challenge_active = true;
    global.random_challenge_snapshot = "";
    global.save_data.random_challenge.current = random_challenge_clone(_template);
    save_file(global.save_slot);
    return true;
}

function random_challenge_add_unique(_array, _value) {
    if (array_get_index(_array, _value) == -1) array_push(_array, _value);
}

function random_challenge_collect_preview_enemy_types(_level_file, _level_data, _has_water) {
    var _out = [];
    var _waves = _level_file.waves;
    for (var i = 0; i < array_length(_waves); i++) {
        var _subwaves = _waves[i].subwaves;
        if (!is_array(_subwaves)) continue;
        for (var j = 0; j < array_length(_subwaves); j++) {
            var _enemy_list = _subwaves[j].enemy_list;
            if (!is_array(_enemy_list)) continue;
            for (var k = 0; k < array_length(_enemy_list); k++) {
                random_challenge_add_unique(_out, _enemy_list[k].type);
            }
        }
    }
    var _level_id = _level_data.id;
    if (_level_id == "pudding_island_daytime" || _level_id == "pudding_island_night") {
        random_challenge_add_unique(_out, "normal_mouse");
        random_challenge_add_unique(_out, "football_fan_mouse");
        random_challenge_add_unique(_out, "iron_pan_mouse");
    }
    if (_level_id == "abyss" || _level_id == "cocoa_island_night") {
        random_challenge_add_unique(_out, "bat_mouse");
    }
    if (variable_struct_exists(_level_file, "events") && is_array(_level_file.events)) {
        var _events = _level_file.events;
        for (var e = 0; e < array_length(_events); e++) {
            var _event_id = _events[e].id;
            if (_event_id == "bat_mouse_spawn") random_challenge_add_unique(_out, "bat_mouse");
            if (_event_id == "assault_mouse_spawn" && _has_water) random_challenge_add_unique(_out, "assault_mouse");
            if (_event_id == "mouse_hole_spawn") {
                random_challenge_add_unique(_out, "normal_mouse");
                random_challenge_add_unique(_out, "football_fan_mouse");
                random_challenge_add_unique(_out, "iron_pan_mouse");
            }
        }
    }
    return _out;
}

function random_challenge_collect_preview_boss_types(_level_file) {
    var _out = [];
    var _waves = _level_file.waves;
    for (var i = 0; i < array_length(_waves); i++) {
        if (!_waves[i].boss_wave) continue;
        if (_waves[i].boss != "") random_challenge_add_unique(_out, _waves[i].boss);
        if (variable_struct_exists(_waves[i], "boss2") && _waves[i].boss2 != "") {
            random_challenge_add_unique(_out, _waves[i].boss2);
        }
    }
    return _out;
}

function random_challenge_sync_readyroom() {
    if (!instance_exists(obj_readyroom_manager)) return;
    var _manager = instance_find(obj_readyroom_manager, 0);
    if (_manager == noone) return;
    _manager.enemy_type_list = random_challenge_collect_preview_enemy_types(
        global.level_file,
        global.level_data,
        random_challenge_has_water(global.level_file)
    );
    _manager.boss_type_list = random_challenge_collect_preview_boss_types(global.level_file);
}

function random_challenge_battle_snapshot() {
    if (!global.random_challenge_active) return;
    if (global.random_challenge_snapshot != "") return;
    global.random_challenge_snapshot = json_stringify(global.save_data);
}

function random_challenge_restore_snapshot() {
    if (global.random_challenge_snapshot == "") return false;
    var _snapshot = global.random_challenge_snapshot;
    global.random_challenge_snapshot = "";
    try {
        var _data = json_parse(_snapshot);
        if (is_struct(_data)) global.save_data = _data;
    }
    catch (e) {
        return false;
    }
    global.is_paused = false;
    global.game_over = false;
    global.show_menu = false;
    return true;
}

function random_challenge_leave_mode() {
    random_challenge_restore_snapshot();
    global.random_challenge_active = false;
    global.map_id = "delicious_island";
    global.map_name = "美味岛";
}
