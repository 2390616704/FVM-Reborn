event_inherited();

plant_id = "coffee_pot";
obj_type = object_index;
current_level = 1;
event_user(0);

sprite_index = spr_coffee_pot_body;
image_index = clamp(shape, 0, 2);
image_speed = 0;
image_xscale = 1;
image_yscale = 1;

if (global.level_file.level_time_feature == "daytime" && shape < 1) {
    state = CARD_STATE.SLEEP;
}

attack_anim = 12;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
target_type = "pierce";
is_slowdown = false;

awake_anim = 5;
anim_timer = 0;
wake_timer = 0;

upper_pivot = 35;
spout_offset_x = 70;
spout_offset_y = -76;

recoil = 0;
muzzle_flash = 0;

visual_time = random(1000);
breath_phase = random(360);
attack_visual = 0;
sleep_visual = (state == CARD_STATE.SLEEP) ? 1 : 0;
body_angle = 0;
body_sx = 1;
body_sy = 1;
body_ox = 0;
body_oy = 0;
lid_offset = 0;
liquid_angle = 0;
liquid_ox = 0;
liquid_oy = 0;
face_index = (shape >= 2) ? 2 : ((shape == 1) ? 1 : 0);
