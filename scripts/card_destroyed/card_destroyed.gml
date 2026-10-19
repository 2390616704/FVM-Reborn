function plant_consume_lethal_block(plant) {
    if (!instance_exists(plant)) return false;
    if (!variable_instance_exists(plant, "lethal_blocks") || plant.lethal_blocks <= 0) return false;

    plant.lethal_blocks--;
    if (variable_instance_exists(plant, "lethal_restore_full") && plant.lethal_restore_full) {
        plant.hp = plant.max_hp;
    } else if (variable_instance_exists(plant, "lethal_blocks_max") && plant.lethal_blocks_max > 0) {
        plant.hp = plant.max_hp * (plant.lethal_blocks / plant.lethal_blocks_max);
    } else {
        plant.hp = plant.max_hp;
    }
    plant.flash_value = 150;
    return true;
}

function plant_find_guard(target, require_lethal_block) {
    if (!instance_exists(target)) return noone;

    var best_guard = noone;
    var best_distance = 99999;
    with (obj_card_parent) {
        if (id == target.id) continue;
        if (!variable_instance_exists(id, "lethal_guard") || !lethal_guard) continue;
        if (!variable_instance_exists(id, "lethal_guard_depth")) continue;
        if (require_lethal_block && lethal_blocks <= 0) continue;
        if (!require_lethal_block && hp <= 0) continue;
        if (target.hp > hp) continue;
        if (grid_row < target.grid_row - 1 || grid_row > target.grid_row + 1) continue;

        if (target.grid_col >= grid_col - lethal_guard_depth && target.grid_col <= grid_col - 1) {
            var distance = grid_col - target.grid_col;
            if (distance < best_distance) {
                best_distance = distance;
                best_guard = id;
            }
        }
    }
    return best_guard;
}

function plant_apply_normal_damage(plant, damage) {
    if (!instance_exists(plant) || plant.invincible) return;

    var guard = plant_find_guard(plant, false);
    var receiver = (guard != noone) ? guard : plant;
    receiver.hp -= damage;
    with (receiver) event_user(2);
}

function plant_apply_overlap_attack(target, damage) {
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

    plant_apply_normal_damage(main_plant, damage);

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

    var guard = plant_find_guard(plant, true);
    if (guard != noone && plant_consume_lethal_block(guard)) {
        if (guard.hp > 0) plant_push_attacker(attacker);
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
    attacker.x += global.grid_cell_size_x;
    if (variable_instance_exists(attacker, "grid_col")) attacker.grid_col += 1;
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