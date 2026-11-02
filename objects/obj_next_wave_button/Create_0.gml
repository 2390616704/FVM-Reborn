image_xscale = 0.9
image_yscale = 0.9
image_speed = 0
image_index = 0
button_width = sprite_get_width(spr_common_button) * image_xscale
button_height = sprite_get_height(spr_common_button) * image_xscale
depth = -2900

function can_advance_wave() {
	if (global.is_paused || global.game_over) return false
	if (obj_battle.level_stage != "pre") return false
	if (obj_battle.current_wave >= obj_battle.total_wave) return false
	if (!(global.random_challenge_active || global.save_data.unlocked_items.elite_unlocked || obj_battle.current_wave < global.level_file.elite_wave)) return false
	return true
}

function mouse_over_next_wave_button() {
	var _l = x - button_width / 2
	var _r = x + button_width / 2
	var _t = y - button_height / 2
	var _b = y + button_height / 2
	return point_in_rectangle(mouse_x, mouse_y, _l, _t, _r, _b) || point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _l, _t, _r, _b)
}
