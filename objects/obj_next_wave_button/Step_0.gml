if (!can_advance_wave()) exit

if (mouse_over_next_wave_button() && mouse_check_button_pressed(mb_left)) {
	var _wave_data = global.level_file.waves[obj_battle.current_wave]
	var _boss_pending = _wave_data.boss_wave && obj_battle.level_stage != "boss" && (global.random_challenge_active || global.save_data.unlocked_items.elite_unlocked)
	if (_boss_pending) {
		obj_battle.wave_timer = 2
	}
	else {
		with (obj_battle) advance_wave()
	}
	global.audio.play(snd_button, 0, 0)
}
