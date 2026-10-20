// 从网格数据中移除
if hp < max_hp && !invincible{
	obj_task_manager.card_loss ++
}
if hp <= 0 && !invincible && plant_type != "player" && plant_id != "player" && plant_id != "melon_shield" && instance_exists(parent_card_slot) {
	parent_card_slot.queue_auto_replant(id);
}
card_destroyed(id);