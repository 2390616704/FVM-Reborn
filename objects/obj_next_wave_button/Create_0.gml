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
