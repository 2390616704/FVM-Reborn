event_inherited();
plant_id = "sugar_painting_sword";
obj_type = object_index;
current_level = 1;
event_user(0);

full_sprite = spr_sugar_painting_sword;
hilt_sprite = spr_sugar_painting_sword_hilt;
if shape == 1 {
    full_sprite = spr_sugar_painting_sword_1;
    hilt_sprite = spr_sugar_painting_sword_hilt_1;
}
else if shape == 2 {
    full_sprite = spr_sugar_painting_sword_2;
    hilt_sprite = spr_sugar_painting_sword_hilt_2;
}
sprite_index = full_sprite;

idle_anim = 5;
attack_anim = 0;
flash_speed = 6;
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;

row_range = 2;
left_range = 6;
col_range = range;
if (col_range <= 0) col_range = 6;
hit_radius = global.grid_cell_size_x * (0.45 + 0.10 * shape);
travel_speed = 2017;
blade_offset = 32;

target_type = "pierce";
damage_type = "normal";
if shape >= 2 {
    target_type = "all";
    damage_type = "pierce";
}

blade_inst = noone;
image_angle = 0;
