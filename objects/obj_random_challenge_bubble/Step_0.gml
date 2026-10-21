if instance_exists(obj_player_info_ui) && obj_player_info_ui.menu_type != 0 {
    image_index = 0
    pressed_inside = false
    exit
}
if room_transition_state().mode != 0 {
    image_index = 0
    pressed_inside = false
    exit
}

var _inside = point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)
if _inside && mouse_check_button_pressed(mb_left) pressed_inside = true
if !mouse_check_button(mb_left) {
    if pressed_inside && _inside {
        if random_challenge_enter() {
            global.audio.play(snd_button, 0, 0)
            texture_prefetch("cards")
            global.gui_stack.to(room_ready)
        }
    }
    pressed_inside = false
}

if _inside {
    image_index = mouse_check_button(mb_left) ? 2 : 1
}
else {
    image_index = 0
}
