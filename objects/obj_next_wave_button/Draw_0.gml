if (!can_advance_wave()) exit

var _hover = mouse_over_next_wave_button()
var _frame = 0
if (_hover) {
	_frame = mouse_check_button(mb_left) ? 2 : 1
}

draw_sprite_ext(spr_common_button, _frame, x, y, image_xscale, image_yscale, 0, c_white, 1)

draw_set_font(font_yuan)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_colour(c_white)
draw_text_transformed(x, y - 1, "下一波", 0.8, 0.8, 0)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
