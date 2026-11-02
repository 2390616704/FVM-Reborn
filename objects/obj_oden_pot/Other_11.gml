var _sx = x;
var _sy = y;
var _shape = shape;

if (!variable_global_exists("oden_spray_mgr") || !instance_exists(global.oden_spray_mgr)) {
    instance_create_depth(0, 0, -1000, obj_oden_spray_manager);
}

with (global.oden_spray_mgr) {
    if (_shape < 2) {
        mgr_spawn_line(_sx + 50, _sy - 75, 0, 320, 70, 0, random(9999));
        mgr_spawn_line(_sx, _sy - 95, 90, 200, 60, 0, random(9999));
        mgr_spawn_line(_sx, _sy - 45, -90, 200, 60, 0, random(9999));
    } else {
        mgr_spawn_burst(_sx, _sy - 45, 240, 2, random(9999));
    }
}

if (_shape < 2) {
    var inst = instance_create_depth(x + 50, y - 75, depth - 500, obj_coffeepot_bullet);
    global.audio.play(snd_coffee_pot_attack, 0, 0);
    inst.damage = atk;
    inst.move_speed = 0;
    inst.shape = shape;
    inst.row = grid_row;
    inst.start_col = grid_col;
    inst.sprite_index = spr_odenpot_bullet;
    inst.visible = false;
    if (shape == 1) {
        inst.sprite_index = spr_odenpot_bullet_1;
    }

    var inst2 = instance_create_depth(x, y - 95, depth - 500, obj_odenpot_bullet_vertical);
    global.audio.play(snd_coffee_pot_attack, 0, 0);
    inst2.damage = atk;
    inst2.move_speed = 0;
    inst2.shape = shape;
    inst2.row = grid_row;
    inst2.start_col = grid_col;
    inst2.sprite_index = spr_odenpot_bullet;
    inst2.image_angle = 90;
    inst2.visible = false;
    if (shape == 1) {
        inst2.sprite_index = spr_odenpot_bullet_1;
    }

    var inst3 = instance_create_depth(x, y - 45, depth - 500, obj_odenpot_bullet_vertical);
    global.audio.play(snd_coffee_pot_attack, 0, 0);
    inst3.damage = atk;
    inst3.move_speed = 0;
    inst3.shape = shape;
    inst3.row = grid_row;
    inst3.start_col = grid_col;
    inst3.sprite_index = spr_odenpot_bullet;
    inst3.image_angle = -90;
    inst3.visible = false;
    if (shape == 1) {
        inst3.sprite_index = spr_odenpot_bullet_1;
    }
} else {
    var inst4 = instance_create_depth(x, y - 45, depth - 500, obj_odenpot_bullet_vertical);
    global.audio.play(snd_coffee_pot_attack, 0, 0);
    inst4.damage = atk;
    inst4.move_speed = 0;
    inst4.shape = shape;
    inst4.row = grid_row;
    inst4.start_col = grid_col;
    inst4.visible = false;
}
