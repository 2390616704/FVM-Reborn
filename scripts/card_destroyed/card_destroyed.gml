function plant_consume_lethal_block(plant) {
    if (!instance_exists(plant)) return false;
    if (!variable_instance_exists(plant, "lethal_blocks") || plant.lethal_blocks <= 0) return false;

    plant.lethal_blocks--;
    if (variable_instance_exists(plant, "lethal_restore_full") && plant.lethal_restore_full) {
        plant.hp = plant.max_hp;
    } else {
        var lethal_damage_cap = plant.max_hp / 8;
        plant.hp = max(1, plant.hp - lethal_damage_cap);
    }
    plant.flash_value = 150;
    return true;
}

function plant_is_hidden(plant) {
    return instance_exists(plant) &&
        variable_instance_exists(plant, "is_hidden") &&
        plant.is_hidden;
}

function plant_find_guard(target, require_lethal_block) {
    if (!instance_exists(target)) return noone;

    var best_guard = noone;
    var best_hp = 999999999;
    var best_distance = 999999999;
    with (obj_card_parent) {
        if (id == target.id) continue;
        if (!variable_instance_exists(id, "lethal_guard") || !lethal_guard) continue;
        if (hp <= 0 || plant_is_hidden(id)) continue;
        if (require_lethal_block && lethal_blocks <= 0) continue;
        if (!variable_instance_exists(id, "lethal_guard_radius")) continue;

        var row_distance = abs(grid_row - target.grid_row);
        var col_distance = abs(grid_col - target.grid_col);
        var col_radius = lethal_guard_radius;
        if (variable_instance_exists(id, "lethal_guard_col_radius")) col_radius = lethal_guard_col_radius;
        if (col_distance > col_radius) continue;
        if (!(variable_instance_exists(id, "lethal_guard_all_rows") && lethal_guard_all_rows)) {
            var row_radius = lethal_guard_radius;
            if (variable_instance_exists(id, "lethal_guard_row_radius")) row_radius = lethal_guard_row_radius;
            if (row_distance > row_radius) continue;
        }

        var distance = max(row_distance, col_distance);
        if (best_guard == noone || hp < best_hp || (hp == best_hp && distance < best_distance)) {
            best_hp = hp;
            best_distance = distance;
            best_guard = id;
        }
    }
    return best_guard;
}

function melon_shield_find_at(col, row) {
    var melon = noone;
    with (obj_melon_shield) {
        if (hp > 0 && grid_col == col && grid_row == row) {
            melon = id;
        }
    }
    return melon;
}

function melon_shield_reflect(melon, original_damage) {
    var _x = melon.x;
    var _y = melon.y;
    var _range = 250;
    var _enemies = [];
    with (obj_enemy_parent) {
        if (hp > 0 &&
            point_distance(x, y, _x, _y) < _range &&
            grid_row >= melon.grid_row - 1 &&
            grid_row <= melon.grid_row + 1) {
            array_push(_enemies, id);
        }
    }
    if (array_length(_enemies) == 0) return;

    var _total = min(original_damage, 1000);
    if (_total <= 0) return;
    var _share = _total / array_length(_enemies);
    for (var i = 0; i < array_length(_enemies); i++) {
        var _enemy = _enemies[i];
        if (!instance_exists(_enemy)) continue;
        _enemy.damage_amount = _share;
        _enemy.damage_type = "normal";
        with (_enemy) event_user(0);
    }
}

function melon_shield_create_flame(melon, original_damage) {
    var _value = min(original_damage * 0.5, 1000);
    if (_value <= 0) return;
    var inst = instance_create_depth(melon.x, melon.y - 60, melon.depth - 1000, obj_flame);
    inst.value = _value;
}

function melon_stealth_apply(plant) {
    if (!instance_exists(plant)) return;
    if (!variable_instance_exists(plant, "is_hidden")) return;
    if (!plant.is_hidden) {
        plant.stealth_original_alpha = plant.image_alpha;
        plant.stealth_original_invincible = plant.invincible;
        plant.is_hidden = true;
    }
    plant.image_alpha = 0.75;
    plant.invincible = true;
}

function melon_stealth_restore(plant) {
    if (!instance_exists(plant) || !variable_instance_exists(plant, "is_hidden") || !plant.is_hidden) return;
    plant.image_alpha = variable_instance_exists(plant, "stealth_original_alpha") ? plant.stealth_original_alpha : 1;
    plant.invincible = variable_instance_exists(plant, "stealth_original_invincible") ? plant.stealth_original_invincible : false;
    plant.is_hidden = false;
}

function melon_stealth_trigger(col, row) {
    if (!variable_global_exists("stealth_timers")) return;
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) return;
    global.stealth_timers[row][col] = 300;
    with (obj_card_parent) {
        if (grid_col == col && grid_row == row) {
            melon_stealth_apply(id);
        }
    }
}

function melon_stealth_update() {
    if (!variable_global_exists("stealth_timers")) return;

    for (var r = 0; r < global.grid_rows; r++) {
        for (var c = 0; c < global.grid_cols; c++) {
            if (global.stealth_timers[r][c] > 0) {
                global.stealth_timers[r][c]--;
            }
        }
    }

    with (obj_card_parent) {
        var active = grid_col >= 0 && grid_col < global.grid_cols &&
            grid_row >= 0 && grid_row < global.grid_rows &&
            global.stealth_timers[grid_row][grid_col] > 0;
        if (active) {
            if (variable_instance_exists(id, "is_hidden") && is_hidden) {
                image_alpha = 0.75;
                invincible = true;
            } else {
                melon_stealth_apply(id);
            }
        } else if (variable_instance_exists(id, "is_hidden") && is_hidden) {
            melon_stealth_restore(id);
        }
    }
}

function plant_damage_attacker(attacker, amount) {
    if (attacker == noone || !instance_exists(attacker) || amount <= 0) return;
    if (!variable_instance_exists(attacker, "hp") || attacker.hp <= 0) return;
    if (!variable_instance_exists(attacker, "damage_amount")) return;
    attacker.damage_amount = amount;
    attacker.damage_type = "normal";
    with (attacker) event_user(0);
}

function melon_permanent_hide_apply(plant) {
    if (!instance_exists(plant)) return;
    if (!variable_instance_exists(plant, "is_hidden")) return;
    plant.is_hidden = true;
    plant.image_alpha = 0.75;
}

function melon_permanent_hide_cell(col, row) {
    if (!variable_global_exists("perma_hidden")) return;
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) return;
    global.perma_hidden[row][col] = true;
    with (obj_card_parent) {
        if (grid_col == col && grid_row == row) {
            melon_permanent_hide_apply(id);
        }
    }
}

function melon_shield_ash_destroy(melon) {
    if (!instance_exists(melon)) return;
    var _x = melon.x;
    var _y = melon.y;
    var _depth = melon.depth;
    var _sprite = melon.sprite_index;
    var _image = melon.image_index;
    var inst = instance_create_depth(_x, _y - 20, _depth, obj_mouse_ash_death);
    inst.sprite_index = _sprite;
    inst.image_index = _image;
    inst.special_ash = true;
    melon.bleed_damage = 0;
    melon.hp = 0;
    instance_destroy(melon);
}

function melon_shield_handle_damage(plant, damage, attacker) {
    if (!instance_exists(plant) || damage <= 0) return false;
    if (variable_instance_exists(plant, "invincible") && plant.invincible) return true;

    var melon = melon_shield_find_at(plant.grid_col, plant.grid_row);
    if (melon == noone) return false;
    if (melon.invincible) return true;

    if (false) {
        var original_damage = damage;
        var applied_damage = min(original_damage, 100);
        melon.hp -= applied_damage;
        with (melon) event_user(2);

        if (original_damage > 100 && attacker != noone && instance_exists(attacker) && variable_instance_exists(attacker, "target_plant")) {
            plant_push_attacker(attacker);
        }

        plant_damage_attacker(attacker, applied_damage);

        var survived = melon.hp > 0;
        melon_stealth_trigger(melon.grid_col, melon.grid_row);

        if (survived) {
            if (melon.shape >= 1) melon_shield_reflect(melon, original_damage);
            if (melon.shape >= 2) melon_shield_create_flame(melon, original_damage);
        }
    }

    melon_permanent_hide_cell(melon.grid_col, melon.grid_row);
    melon_shield_ash_destroy(melon);
    return true;
}

function plant_apply_normal_damage(plant, damage, attacker = noone) {
    if (!instance_exists(plant) || plant.invincible) return;
    if (melon_shield_handle_damage(plant, damage, attacker)) return;

    var guard = plant_find_guard(plant, false);
    var receiver = (guard != noone) ? guard : plant;
    var applied_damage = damage;
    if (receiver.plant_type == "shield_outer" && receiver.plant_id != "melon_shield") {
        applied_damage = min(damage, receiver.max_hp / 8);
    }
    receiver.hp -= applied_damage;
    with (receiver) event_user(2);

    if (receiver.plant_type == "shield_outer" && receiver.plant_id != "melon_shield") {
        plant_damage_attacker(attacker, applied_damage);
    }
}

function plant_apply_overlap_attack(target, damage, attacker = noone) {
    if (!instance_exists(target)) return;

    var col = target.grid_col;
    var row = target.grid_row;
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) return;

    var cell_plants = ds_grid_get(global.grid_plants, col, row);
    var main_plant = noone;
    for (var i = 0; i < ds_list_size(cell_plants); i++) {
        var plant = ds_list_find_value(cell_plants, i);
        if (!instance_exists(plant) || plant.hp <= 0 || plant.invincible) continue;
        if (plant.plant_type == "coffee" || plant.plant_type == "player") continue;

        if (main_plant == noone || plant.hp > main_plant.hp || (plant.hp == main_plant.hp && plant == target)) {
            main_plant = plant;
        }
    }
    if (main_plant == noone) return;
    if (melon_shield_handle_damage(main_plant, damage, attacker)) return;

    plant_apply_normal_damage(main_plant, damage, attacker);

    for (var i = 0; i < ds_list_size(cell_plants); i++) {
        var plant = ds_list_find_value(cell_plants, i);
        if (!instance_exists(plant) || plant == main_plant || plant.hp <= 0 || plant.invincible) continue;
        if (plant.plant_type == "coffee" || plant.plant_type == "player") continue;

        plant.hp -= 1;
        with (plant) event_user(2);
    }
}

function plant_apply_boss_lethal(plant, attacker) {
    if (!instance_exists(plant)) return;
    if (variable_instance_exists(plant, "invincible") && plant.invincible) return;
    if (melon_shield_handle_damage(plant, 9999999, attacker)) return;

    var guard = plant_find_guard(plant, false);
    if (guard != noone && guard.plant_type == "shield_outer" && guard.plant_id != "melon_shield") {
        plant_apply_normal_damage(guard, 9999999, attacker);
        if (guard.hp > 0) plant_push_attacker(attacker);
        return;
    }
    if (guard != noone && plant_consume_lethal_block(guard)) {
        if (guard.hp > 0) plant_push_attacker(attacker);
        return;
    }
    if (plant.plant_type == "shield_outer" && plant.plant_id != "melon_shield") {
        plant_apply_normal_damage(plant, 9999999, attacker);
        if (plant.hp > 0) plant_push_attacker(attacker);
        return;
    }
    if (plant_consume_lethal_block(plant)) {
        if (plant.hp > 0) plant_push_attacker(attacker);
        return;
    }

    plant.hp -= 9999999;
}

function plant_push_attacker(attacker) {
    if (!instance_exists(attacker)) return;
    if (!variable_instance_exists(attacker, "hp") || attacker.hp <= 0) return;
    var max_x = global.grid_offset_x + (global.grid_cols - 1) * global.grid_cell_size_x + global.grid_cell_size_x / 2;
    attacker.x = min(attacker.x + global.grid_cell_size_x, max_x);
    if (variable_instance_exists(attacker, "grid_col")) {
        attacker.grid_col = min(attacker.grid_col + 1, global.grid_cols - 1);
    }
}

function plant_push_attacker_light(attacker) {
    if (!instance_exists(attacker)) return;
    if (!variable_instance_exists(attacker, "hp") || attacker.hp <= 0) return;
    var max_x = global.grid_offset_x + (global.grid_cols - 1) * global.grid_cell_size_x + global.grid_cell_size_x / 2;
    attacker.x = min(attacker.x + global.grid_cell_size_x * 0.05, max_x);
}

/// @function plant_destroyed(plant_inst)
/// @description 当植物销毁时调用，更新网格数据
/// @param {instance} plant_inst 植物实例
function card_destroyed(plant_inst) {
    var col = plant_inst.grid_col;
    var row = plant_inst.grid_row;
    
    // 检查位置是否有效
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) {
        return;
    }
    
    // 获取该网格的植物列表
    var plant_list = ds_grid_get(global.grid_plants, col, row);
    
    // 从列表中移除植物
    var index = ds_list_find_index(plant_list, plant_inst);
    if (index != -1) {
        ds_list_delete(plant_list, index);
    }
    
    // 更新剩余植物的深度偏移
    //update_card_depths(col, row);
}