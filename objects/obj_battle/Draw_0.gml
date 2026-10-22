draw_sprite(global.level_data.level_sprite,map_spr_index,0,0)

draw_set_alpha(0.25)
draw_set_color(c_white)
var _grid_right = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x
var _grid_bottom = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y
for (var _gc = 0; _gc <= global.grid_cols; _gc++) {
	var _gx = global.grid_offset_x + _gc * global.grid_cell_size_x
	draw_line(_gx, global.grid_offset_y, _gx, _grid_bottom)
}
for (var _gr = 0; _gr <= global.grid_rows; _gr++) {
	var _gy = global.grid_offset_y + _gr * global.grid_cell_size_y
	draw_line(global.grid_offset_x, _gy, _grid_right, _gy)
}
draw_set_alpha(1)

enemy_guardian_draw_lines()

draw_set_valign(fa_top)
draw_set_halign(fa_left)
draw_set_color(c_white)
draw_set_font(font_yuan)
draw_text(0,0,"FPS:"+string(fps))
draw_text(0,25,"加速:"+(speed_up ? "开" : "关") + "（shift）")
draw_text(0,50,"暂停（空格）\n菜单（ESC）")
