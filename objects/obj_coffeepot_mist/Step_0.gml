if (global.is_paused) exit;

visual_time += 1;
life -= 1;
attack_timer += 1;

var _cells = (shape >= 2) ? max(1, global.grid_cols + 1 - start_col) : 4;
spray_len = _cells * global.grid_cell_size_x;

if (attack_timer == 1) {
    if (!variable_global_exists("coffee_mist_mgr") || !instance_exists(global.coffee_mist_mgr)) {
        instance_create_depth(0, 0, -1000, obj_coffeepot_mist_manager);
    }
    with (global.coffee_mist_mgr) {
        mgr_emit(other.x, other.y, other.spray_len, other.spray_h, other.shape, other.visual_seed);
    }
}

if (attack_timer == 2) {
    with (obj_enemy_parent) {
        var _end_col = (other.shape >= 2) ? global.grid_cols + 1 : other.start_col + 4;
        if (hp > 0 && grid_row == other.row && grid_col >= other.start_col && grid_col <= _end_col && can_hit(other.target_type, target_type)) {
            global.audio.play(hit_sound, 0, 0);
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }
    }
}

if (life <= 0 || x > 2200 || y > 1200 || x < 0 || y < 0) {
    instance_destroy();
}
