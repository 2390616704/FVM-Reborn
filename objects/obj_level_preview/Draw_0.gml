draw_set_alpha(1)
draw_sprite(global.level_data.level_sprite,0,0,0)
draw_set_color(c_black)
draw_set_alpha(0.7)
draw_rectangle(0,0,room_width,room_height,0)
draw_set_alpha(1)
draw_set_font(font_yuan)
draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_text(20,20,"右键点击或按ESC返回关卡")
draw_text(40,180,"普通敌人")
draw_text(40,820,"BOSS")
if global.random_challenge_active {
    if feedback_timer > 0 {
        draw_set_font(font_yuan)
        draw_set_halign(fa_center)
        draw_set_valign(fa_middle)
        draw_set_color(c_white)
        draw_text(room_width / 2, 970, feedback_text)
    }
    draw_set_font(font_yuan)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_set_color(c_white)
    for (var bi = 0; bi < array_length(random_buttons); bi++) {
        var _btn = random_buttons[bi];
        var _frame = _btn.pressed ? 2 : (_btn.hover ? 1 : 0);
        draw_sprite_ext(spr_option_common_button, _frame, _btn.x, _btn.y, _btn.scale, _btn.scale, 0, c_white, 1);
        draw_text(_btn.x, _btn.y, _btn.label);
    }
    draw_set_color(c_white)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}
