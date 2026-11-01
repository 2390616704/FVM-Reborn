event_inherited();

plant_id = "ice_ball_cup";
current_level = 1;
obj_type = object_index;

beam_list = [];
beam_visual_time = 0;
charge_visual = 0;
general_beam_count = 4;
air_beam_count = 0;
general_target_type = "normal";
target_type = general_target_type;
orb_offset_y = -118;

sync_beams = function() {
    if (!is_array(beam_list)) beam_list = [];
    var total = general_beam_count + air_beam_count;
    while (array_length(beam_list) > total) {
        var n = array_length(beam_list);
        var old_beam = beam_list[n - 1];
        array_delete(beam_list, n - 1, 1);
        if (instance_exists(old_beam)) instance_destroy(old_beam);
    }
    while (array_length(beam_list) < total) {
        var idx = array_length(beam_list);
        var new_beam = instance_create_depth(x, y, depth - 500, obj_ice_ball_cup_beam);
        new_beam.owner = id;
        new_beam.beam_type = (idx < general_beam_count) ? "general" : "air";
        array_push(beam_list, new_beam);
    }
    for (var i = 0; i < array_length(beam_list); i++) {
        var b = beam_list[i];
        if (!instance_exists(b)) continue;
        b.owner = id;
        b.beam_type = (i < general_beam_count) ? "general" : "air";
    }
};

event_user(0);

sprite_index = spr_ice_ball_cup_orb;
if shape == 1 { sprite_index = spr_ice_ball_cup_orb_1; }
if shape == 2 { sprite_index = spr_ice_ball_cup_orb_2; }

idle_anim = 0;
attack_anim = 0;
flash_speed = 2;
plant_type = "normal";
is_slowdown = false;
current_hp = hp;

general_target_type = (shape >= 2) ? "all" : "normal";
general_beam_count = (shape >= 2) ? 5 : 4;
air_beam_count = (shape >= 1) ? 1 : 0;
target_type = general_target_type;

sync_beams();
