event_inherited();

if (!is_array(beam_list)) exit;

for (var i = 0; i < array_length(beam_list); i++) {
    if (instance_exists(beam_list[i])) instance_destroy(beam_list[i]);
}
