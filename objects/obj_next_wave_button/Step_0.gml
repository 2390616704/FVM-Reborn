if (!can_advance_wave()) exit

var _mx = mouse_x
var _my = mouse_y
var _hover = point_in_rectangle(_mx, _my, x - button_width / 2, y - button_height / 2, x + button_width / 2, y + button_height / 2)

if (_hover && mouse_check_button_released(mb_left)) {
	obj_battle.wave_timer = max(obj_battle.wave_timer, 2)
	global.audio.play(snd_button, 0, 0)
}
