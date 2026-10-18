//create事件
cooldown = 7 * 60
card_obj = obj_small_fire
card_spr = spr_small_fire
place_preview = spr_small_fire
card_id = ""
cost = 50
current_cost = 0
night = false
cooldown_timer = 30000
max_charges = 3
charges = 1
reloading = false
startup_reload_pending = true
loaded_charge = false
description = "小火炉:生产火苗"
slot_index = 0
clevel = 0
cshape = 0
cskill = 0
info_got = false

is_ready = true           // 卡槽是否可用
is_selected = false       // 卡槽是否被选中
hover_alpha = 0           // 悬停提示透明度
cooling_alpha = 0         // 冷却覆盖层透明度

selected_preview = noone;  // 当前选中的预览对象
preview_alpha = 0.5;      // 放置预览的透明度

pending_ghosts = [];       // 冷却期间预放置的虚影队列

image_xscale = 0.33
image_yscale = 0.33
image_speed = 0

cooldown_ignore_list = ["ice_cream","magic_chicken"]

//选择卡槽逻辑
function select_slot(){
	// 选中当前卡槽
        is_selected = true;
        
        // 如果有全局选中卡槽，取消其选中状态
		var shovel_slot = instance_find(obj_shovel_slot, 0);
        if (instance_exists(shovel_slot) && shovel_slot.is_selected) {
            deselect_shovel();
        }
        if (global.selected_slot != noone && global.selected_slot != id) {
            global.selected_slot.is_selected = false;
            instance_destroy(global.selected_slot.selected_preview);
            global.selected_slot.selected_preview = noone;
        }
        audio_play_sound(snd_card_lift,0,0)
        // 设置全局选中卡槽为当前卡槽
        global.selected_slot = id;
}

function resolve_placement_cell(mx, my){
	var found_plat = noone;
	var shift_x = 0;
	var shift_y = 0;
	var logical_col = -1;
	var logical_row = -1;
	var grid_pos_visual = get_grid_position_from_world(mx, my);
	var direct_in_platform = false;

	with (obj_platform) {
		var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");
		var sx = is_axis_x ? visual_x_shift : 0;
		var sy = (!is_axis_x) ? visual_y_shift : 0;
		var adj_x = mx - sx;
		var adj_y = my - sy;
		var grid_pos_adj = get_grid_position_from_world(adj_x, adj_y);

		var c_off = is_axis_x ? current_offset : 0;
		var r_off = (!is_axis_x) ? current_offset : 0;
		var p_start_c = start_col + c_off;
		var p_start_r = start_row + r_off;

		if (grid_pos_adj.col >= p_start_c && grid_pos_adj.col < p_start_c + width &&
			grid_pos_adj.row >= p_start_r && grid_pos_adj.row < p_start_r + length) {
			found_plat = id;
			logical_col = grid_pos_adj.col;
			logical_row = grid_pos_adj.row;
			shift_x = sx;
			shift_y = sy;
			break;
		}

		if (!direct_in_platform &&
			grid_pos_visual.col >= p_start_c && grid_pos_visual.col < p_start_c + width &&
			grid_pos_visual.row >= p_start_r && grid_pos_visual.row < p_start_r + length) {
			direct_in_platform = true;
		}
	}

	if (found_plat == noone) {
		if (direct_in_platform) {
			logical_col = -1;
			logical_row = -1;
		} else {
			logical_col = grid_pos_visual.col;
			logical_row = grid_pos_visual.row;
		}
	}

	return {col: logical_col, row: logical_row, shift_x: shift_x, shift_y: shift_y, platform: found_plat};
}

function deselect_slot_after_place(){
	is_selected = false;
	if (selected_preview != noone && instance_exists(selected_preview)) {
		instance_destroy(selected_preview);
	}
	selected_preview = noone;
	global.selected_slot = noone;
}

function consume_charge(){
	if (charges <= 0) {
		return false;
	}
	charges--;
	if (charges < max_charges && !reloading) {
		reloading = true;
		startup_reload_pending = false;
		cooldown_timer = 0;
	}
	is_ready = (charges > 0 && global.flame >= current_cost);
	return true;
}

function finish_direct_placement(){
	if (charges <= 0 || global.flame < current_cost) {
		deselect_slot_after_place();
	}
}

function clear_pending_ghosts(refund){
	var total = 0;
	for (var i = 0; i < array_length(pending_ghosts); i++) {
		var rec = pending_ghosts[i];
		if (instance_exists(rec.ghost)) {
			instance_destroy(rec.ghost);
		}
		total += rec.cost;
	}
	if (refund && total > 0) {
		global.flame += total;
	}
	pending_ghosts = [];
}

function spawn_pending_ghost(cell, card_data){
	var logical_world = get_world_position_from_grid(cell.col, cell.row);
	var ghost = instance_create_depth(logical_world.x + cell.shift_x, logical_world.y + cell.shift_y, calculate_plant_depth(cell.col, cell.row, card_data[? "plant_type"]) - 5, obj_card_preview);
	ghost.is_phantom = true;
	ghost.preview_sprite = (place_preview != undefined) ? place_preview : card_spr;
	ghost.parent_slot = id;
	ghost.card_id = card_id;
	ghost.x = logical_world.x + cell.shift_x;
	ghost.y = logical_world.y + cell.shift_y;
	ghost.depth = calculate_plant_depth(cell.col, cell.row, card_data[? "plant_type"]) - 5;

	var rec = {
		ghost: ghost,
		card_data: card_data,
		card_obj: card_obj,
		card_id: card_id,
		cost: current_cost,
		col: cell.col,
		row: cell.row,
		shift_x: cell.shift_x,
		shift_y: cell.shift_y,
		platform: cell.platform,
		offset_col: 0,
		offset_row: 0,
		prev_place_id: global.prev_place_id
	};
	if (cell.platform != noone) {
		var is_axis_x = (variable_instance_exists(cell.platform, "move_axis") && cell.platform.move_axis == "x");
		var base_c = cell.platform.start_col + (is_axis_x ? cell.platform.current_offset : 0);
		var base_r = cell.platform.start_row + (!is_axis_x ? cell.platform.current_offset : 0);
		rec.offset_col = cell.col - base_c;
		rec.offset_row = cell.row - base_r;
	}
	array_push(pending_ghosts, rec);
	global.flame -= current_cost;
}

function place_card_at(col, row, shift_x, shift_y, card_data, plant_obj, cost, deduct_cost, platform=noone){
	var logical_world = get_world_position_from_grid(col, row);
	var plant_list = ds_grid_get(global.grid_plants, col, row);
	var target_card_id = card_data[? "target_card"];

	if (card_data[? "feature_type"] == "upgrade"){
		if (target_card_id != undefined && target_card_id != "none") {
			for (var i = 0; i < ds_list_size(plant_list); i++) {
				var plant = ds_list_find_value(plant_list, i);
				if (instance_exists(plant) && variable_instance_exists(plant, "plant_id") && plant.plant_id == target_card_id) {
					card_destroyed(plant);
					instance_destroy(plant);
					break;
				}
			}
		}
	}

	if (global.replace_placement && !global.overlap_planting){
		for (var i = 0; i < ds_list_size(plant_list); i++) {
			var plant = ds_list_find_value(plant_list, i);
			if (instance_exists(plant) && plant.plant_type == card_data[? "plant_type"] && plant.plant_id != "player" && plant.plant_type != "coffee"
			&& !((card_data[? "feature_type"]=="bun" && plant.feature_type == "king_bun")||(card_data[? "feature_type"]=="king_bun" && plant.feature_type == "king_bun"))
			&& !((card_data[? "feature_type"]=="tbun" && plant.feature_type == "king_tbun")||(card_data[? "feature_type"]=="king_tbun" && plant.feature_type == "king_tbun"))) {
				card_destroyed(plant);
				instance_destroy(plant);
			}
		}
	}

	var new_plant = instance_create_depth(logical_world.x + shift_x, logical_world.y + shift_y, 0, plant_obj);
	if (platform != noone && variable_instance_exists(platform, "state") && platform.state == "moving") {
		new_plant.platform_grid_lock = true;
	}
	var depth_value = calculate_plant_depth(col, row, new_plant.plant_type);
	card_created(new_plant, col, row);
	new_plant.depth = depth_value - new_plant.depth_offset * 0.001;

	var terrain_type = global.grid_terrains[row][col].type;
	if (terrain_type == "normal"){
		instance_create_depth(logical_world.x + shift_x, logical_world.y + shift_y, -2, obj_place_effect);
		audio_play_sound(snd_place1,0,0);
	}
	else if (terrain_type == "water"){
		var inst = instance_create_depth(logical_world.x + shift_x, logical_world.y + shift_y + 20, -2500, obj_place_effect);
		inst.sprite_index = spr_enter_water_effect;
		audio_play_sound(snd_enter_water,0,0);
	}

	if (deduct_cost){
		global.flame -= cost;
	}

	return new_plant;
}

//尝试放置逻辑
function try_place_once(){
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
	var can_plant = can_place_at_position(logical_world.x, logical_world.y, card_data[? "plant_type"],card_data[? "feature_type"],card_data[? "target_card"]);

	if (can_plant && global.flame >= current_cost) {
		if (charges > 0) {
			place_card_at(cell.col, cell.row, cell.shift_x, cell.shift_y, card_data, card_obj, current_cost, true, cell.platform);
			consume_charge();
			if array_get_index(cooldown_ignore_list,card_id) == -1{
				global.prev_place_id = card_id
			}
			deselect_slot_after_place();
		}
		else if (cooldown_timer < cooldown && global.pre_place_on_cooldown) {
			spawn_pending_ghost(cell, card_data);
			deselect_slot_after_place();
		}
		else if global.quick_placement {
			deselect_slot_after_place();
		}
	}
	else if global.quick_placement {
		deselect_slot_after_place();
	}
}
