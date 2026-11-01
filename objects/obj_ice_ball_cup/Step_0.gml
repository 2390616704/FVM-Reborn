if (global.is_paused) exit;
event_inherited();

if (!is_array(beam_list)) {
    beam_list = [];
    general_beam_count = (shape >= 2) ? 5 : 4;
    air_beam_count = (shape >= 1) ? 1 : 0;
    sync_beams();
}

general_target_type = (shape >= 2) ? "all" : "normal";
target_type = general_target_type;

var want_general = (shape >= 2) ? 5 : 4;
var want_air = (shape >= 1) ? 1 : 0;
if (want_general != general_beam_count || want_air != air_beam_count) {
    general_beam_count = want_general;
    air_beam_count = want_air;
    sync_beams();
}

for (var i = array_length(beam_list) - 1; i >= 0; i--) {
    if (!instance_exists(beam_list[i])) {
        array_delete(beam_list, i, 1);
    }
}
if (array_length(beam_list) != general_beam_count + air_beam_count) {
    sync_beams();
}

var c = 0;
for (var i = 0; i < array_length(beam_list); i++) {
    var b = beam_list[i];
    if (instance_exists(b) && b.target != noone) {
        c = max(c, b.intensity);
    }
}
charge_visual = lerp(charge_visual, c, 0.2);
beam_visual_time += 1;
