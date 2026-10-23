if global.is_paused {
	exit
}

event_inherited();

var current_flash_speed = flash_speed;
if is_slowdown {
	current_flash_speed *= 2;
}

attack_timer++;

if attack_timer == 1 {
	// 只写回真正的咖啡豆卡槽；万化鸡复制体不污染万化鸡自身价格
	if instance_exists(parent_card_slot) && parent_card_slot.card_id == "coffee_bean" {
		parent_card_slot.cost += 25;
	}

	with (obj_card_parent) {
		if (plant_id != "player" && plant_id != "coffee_bean") {
			if (grid_row == other.grid_row && grid_col == other.grid_col) {
				with (obj_card_slot) {
					if (card_id == other.plant_id && charges < max_charges) {
						startup_reload_pending = false;
						// 固定推进30秒冷却；冷却较短的卡槽可能连续装填多次
						advance_reload(30 * 60);
					}
				}
			}
		}
	}
}

if attack_timer > current_flash_speed * idle_anim - 1 {
	instance_destroy();
}
