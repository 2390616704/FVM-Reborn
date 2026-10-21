if feedback_timer > 0 {
    feedback_timer--
    if feedback_timer <= 0 feedback_text = ""
}
if array_length(mouse_preview_inst) == 0{
	for(var i = 0; i < array_length(enemy_type_list);i++){
		var enemy_data = global.enemy_map[? enemy_type_list[i]]
		var inst = instance_create_depth(300+(i mod 10)*170,300+floor(i / 10)*230,depth-1,obj_mouse_preview)
		inst.sprite_index = enemy_data.spr
		inst.tooltip_text = enemy_data.description + "\n基础生命值：" + string(enemy_data.hp)
		if enemy_data.shield > 0{
			inst.tooltip_text += "\n防具血量：" + string(enemy_data.shield)
		}
		array_push(mouse_preview_inst,inst)
	}
	for(var i = 0; i < array_length(boss_type_list);i++){
		var enemy_data = global.enemy_map[? boss_type_list[i]]
		var inst = instance_create_depth(300+(i mod 5)*340,900+floor(i / 5)*280,depth-1,obj_mouse_preview)
		inst.sprite_index = enemy_data.spr
		inst.tooltip_text = enemy_data.description + "\n基础生命值：" + string(enemy_data.hp)
		array_push(mouse_preview_inst,inst)
	}
}
if global.random_challenge_active {
    for (var bi = 0; bi < array_length(random_buttons); bi++) {
        var _btn = random_buttons[bi];
        var _half_w = 107 * _btn.scale;
        var _half_h = 37.5 * _btn.scale;
        var _inside = point_in_rectangle(mouse_x, mouse_y, _btn.x - _half_w, _btn.y - _half_h, _btn.x + _half_w, _btn.y + _half_h);
        if (_inside) {
            _btn.hover = true;
            if (mouse_check_button_pressed(mb_left)) _btn.pressed = true;
            if (!mouse_check_button(mb_left) && _btn.pressed) {
                _btn.pressed = false;
                var _ok = true;
                if (_btn.action == "enemies") {
                    _ok = random_challenge_refresh_enemies();
                    show_notice(_ok ? "已刷新普通敌人" : "刷新普通敌人失败", 45);
                    feedback_text = _ok ? "已刷新普通敌人" : "刷新普通敌人失败"; feedback_timer = 120;
                }
                else if (_btn.action == "boss") {
                    _ok = random_challenge_refresh_boss();
                    show_notice(_ok ? "已刷新Boss" : "刷新Boss失败", 45);
                    feedback_text = _ok ? "已刷新Boss" : "刷新Boss失败"; feedback_timer = 120;
                }
                else if (_btn.action == "map") {
                    _ok = random_challenge_refresh_map();
                    show_notice(_ok ? "已刷新地图" : "刷新地图失败", 45);
                    feedback_text = _ok ? "已刷新地图" : "刷新地图失败"; feedback_timer = 120;
                }
                else if (_btn.action == "save") {
                    _ok = random_challenge_save_template();
                    show_notice(_ok ? "模板已保存" : "保存模板失败", 45);
                    feedback_text = _ok ? "模板已保存" : "保存模板失败"; feedback_timer = 120;
                }
                else if (_btn.action == "load") {
                    _ok = random_challenge_load_template();
                    show_notice(_ok ? "模板已加载" : "模板不存在或已失效", 45);
                    feedback_text = _ok ? "模板已加载" : "模板不存在或已失效"; feedback_timer = 120;
                }
                if (_btn.action != "save") {
                    with (obj_mouse_preview) instance_destroy();
                    mouse_preview_inst = [];
                    enemy_type_list = random_challenge_collect_preview_enemy_types(
                        global.level_file,
                        global.level_data,
                        random_challenge_has_water(global.level_file)
                    );
                    boss_type_list = random_challenge_collect_preview_boss_types(global.level_file);
                    random_challenge_sync_readyroom();
                }
            }
        }
        else {
            _btn.hover = false;
            _btn.pressed = false;
        }
    }
}
if keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right){
	instance_destroy()
}
