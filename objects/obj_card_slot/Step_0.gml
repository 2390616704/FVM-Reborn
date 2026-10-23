//step事件
if global.is_paused{
	exit
}
if card_id != "magic_chicken"{
	current_cost = cost
	if ds_map_find_value(global.plus_card_map,card_id) != undefined{
		var plus_info = ds_map_find_value(global.plus_card_map,card_id)
		with plus_info[0]{
			if shape < plus_info[1]{
				other.current_cost += 50
			}
		}
	}
}
if global.debug{
	cooldown_timer = cooldown
}

if (startup_reload_pending && info_got) {
	startup_reload_pending = false;
	reloading = true;
	cooldown_timer = 0;
}

loaded_charge = false;
if (reloading) {
	if (cooldown_timer < cooldown) {
		cooldown_timer++;
	}
	if (cooldown_timer >= cooldown) {
		if (charges < max_charges) {
			charges++;
			loaded_charge = true;
		}
		if (charges < max_charges) {
			cooldown_timer = 0;
		} else {
			cooldown_timer = cooldown;
			reloading = false;
		}
	}
}

if (charges <= 0) {
	cooling_alpha = min(cooling_alpha + 0.05, 0.7);
} else {
	cooling_alpha = max(cooling_alpha - 0.05, 0);
}

is_ready = (charges > 0);

// 更新所有预放置虚影的位置和深度
var i = 0;
while (i < array_length(pending_ghosts)) {
	var rec = pending_ghosts[i];
	if (!instance_exists(rec.ghost)) {
		global.flame += rec.cost;
		array_delete(pending_ghosts, i, 1);
		continue;
	}
	if (instance_exists(rec.platform)) {
		var is_axis_x = (variable_instance_exists(rec.platform, "move_axis") && rec.platform.move_axis == "x");
		var c_off = is_axis_x ? rec.platform.current_offset : 0;
		var r_off = (!is_axis_x) ? rec.platform.current_offset : 0;
		rec.col = rec.platform.start_col + c_off + rec.offset_col;
		rec.row = rec.platform.start_row + r_off + rec.offset_row;
		rec.shift_x = is_axis_x ? rec.platform.visual_x_shift : 0;
		rec.shift_y = (!is_axis_x) ? rec.platform.visual_y_shift : 0;

		var rec_world = get_world_position_from_grid(rec.col, rec.row);
		rec.ghost.x = rec_world.x + rec.shift_x;
		rec.ghost.y = rec_world.y + rec.shift_y;
		rec.ghost.depth = calculate_plant_depth(rec.col, rec.row, rec.card_data[? "plant_type"]) - 5;
		pending_ghosts[i] = rec;
	}
	i++;
}

// 每装填一次只实体化最前面的一个虚影
if (loaded_charge && array_length(pending_ghosts) > 0 && charges > 0) {
	materialize_one_pending_ghost();
}

process_auto_replants();

var can_select = (charges > 0 || (reloading && global.pre_place_on_cooldown));

if ((array_length(pending_ghosts) > 0 || array_length(pending_auto_replants) > 0) && mouse_check_button_pressed(mb_right)) {
	if (point_in_rectangle(mouse_x, mouse_y, x-50, y-70, x+50, y+70)) {
		clear_pending_ghosts(true);
		is_ready = (charges > 0);
		show_notice("已取消全部预放置", 60);
		audio_play_sound(snd_button,0,0);
	}
}

// 检测鼠标悬停（用于显示提示）
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var is_hovered = point_in_rectangle(mx, my, x-42, y-55, x+42, y+50);

// 控制悬停提示透明度
if (is_hovered) {
    hover_alpha = min(hover_alpha + 0.1, 1);
} else {
    hover_alpha = 0
}

// 检测鼠标点击（选中卡槽）
if (can_select && mouse_check_button_pressed(mb_left)) {
    mx = mouse_x;
    my = mouse_y;
    
    if (point_in_rectangle(mx, my, x-50, y-70, x+50, y+70)) {
		
        select_slot()
        
        // 创建放置预览对象
        if (selected_preview == noone) {
            selected_preview = instance_create_depth(mouse_x, mouse_y, depth-2, obj_card_preview);
            selected_preview.preview_sprite = card_spr; // 设置预览精灵
			if place_preview != undefined{
				selected_preview.preview_sprite = place_preview
			}
            selected_preview.parent_slot = id; // 设置父卡槽
			selected_preview.card_id = card_id
        }
    }
}

var slot_key = global.keybind_map[? "卡槽" + string(slot_index)];

if keyboard_check_pressed(slot_key) && can_select{
        // 选中当前卡槽
		if !is_selected{
			select_slot()
        
			if global.quick_placement{
				try_place_once()
			}
			else{
	        // 创建放置预览对象
		        if (selected_preview == noone) {
		            selected_preview = instance_create_depth(mouse_x, mouse_y, depth-2, obj_card_preview);
		            selected_preview.preview_sprite = card_spr; // 设置预览精灵
					if place_preview != undefined{
						selected_preview.preview_sprite = place_preview
					}
		            selected_preview.parent_slot = id; // 设置父卡槽
					selected_preview.card_id = card_id
		        }
			}
		}
		else{
			is_selected = false;
	        if (selected_preview != noone && instance_exists(selected_preview)) {
	            instance_destroy(selected_preview);
	        }
	        selected_preview = noone;
	        global.selected_slot = noone;
		}
    }

// 如果当前卡槽被选中，处理放置逻辑
if (is_selected) {
    // 更新预览位置
    if (selected_preview != noone && instance_exists(selected_preview)) {
        selected_preview.x = mouse_x;
        selected_preview.y = mouse_y;
    }
    
    // 右键取消选择
    if (mouse_check_button_pressed(mb_right)) or (keyboard_check_pressed(vk_escape)) {
        is_selected = false;
        if (selected_preview != noone && instance_exists(selected_preview)) {
            instance_destroy(selected_preview);
        }
        selected_preview = noone;
        global.selected_slot = noone;
    }
    
    // 左键尝试放置植物
    if (mouse_check_button_pressed(mb_left)) {
        // 检查是否在可种植区域
		
        var card_shape = get_card_info_simple(card_id).shape
		var card_data = deck_get_card_data(card_id,card_shape)
		
		if card_id == "magic_chicken"{
			if global.prev_place_id != ""{
				card_shape = get_card_info_simple(global.prev_place_id).shape
				card_data = deck_get_card_data(global.prev_place_id,card_shape)
			}
		}
        
        var cell = resolve_placement_cell(mouse_x, mouse_y);
        var logical_world = get_world_position_from_grid(cell.col, cell.row);

        var can_plant = (can_place_at_position(logical_world.x, logical_world.y, card_data[? "plant_type"],card_data[? "feature_type"],card_data[? "target_card"]));
        
        if (can_plant) {
            if (charges > 0) {
                place_card_at(cell.col, cell.row, cell.shift_x, cell.shift_y, card_data, card_obj, current_cost, true, cell.platform);
                consume_charge();
                if array_get_index(cooldown_ignore_list,card_id) == -1{
                    global.prev_place_id = card_id
                }
                finish_direct_placement();
            }
            else if (cooldown_timer < cooldown && global.pre_place_on_cooldown) {
                spawn_pending_ghost(cell, card_data);
            }
        }
    }
}

depth = -1 * slot_index - 1000
if info_got == false{
	event_user(0)
}