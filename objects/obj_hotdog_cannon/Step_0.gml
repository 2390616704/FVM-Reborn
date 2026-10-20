if global.is_paused{
	exit
}
event_inherited(); 
if is_frozen || state == CARD_STATE.SLEEP{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
//检测自身三行内右方是否有敌人
var has_enemy = false
var target_enemy = noone
var min_distance = 10000
has_air = false
target_row = grid_row
with(obj_enemy_parent){
	if (abs(grid_row - other.grid_row) <= 1 && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type,target_type)){
		var distance = grid_col - other.grid_col
		if (distance < min_distance) {
			min_distance = distance
			target_enemy = id
			has_enemy = true
		}
	}
}
if (has_enemy) {
	target_row = target_enemy.grid_row
	has_air = (target_enemy.target_type == "air")
}
//攻击逻辑
if (has_enemy) {
    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
        attack_timer++;
    } else if (attack_timer <= cycle) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } else {
        event_user(1); // 发射子弹
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
	if attack_timer == cycle - 5{
		if has_air || shape >= 2{
			event_user(1)
		}
	}
	if attack_timer == cycle - 10{
		if has_air && shape >= 1{
			event_user(1)
		}
	}
	if attack_timer == cycle - 15{
		if has_air && shape >= 2{
			event_user(1)
		}
	}
} else {
    // 没有符合条件的敌人，重置状态
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}


