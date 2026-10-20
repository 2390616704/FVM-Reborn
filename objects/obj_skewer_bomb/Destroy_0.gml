// Inherit the parent event

// alarm[0]事件 - 实际攻击执行
// 摧毁范围内敌人
var _col = grid_col;
var _row = grid_row;

with (obj_enemy_parent) {
		
	if (target_type == "air" &&
		abs(grid_col - _col) <= 2 &&
		abs(grid_row - _row) <= 2) {
		if (immune_to_ash && hp>other.atk) {
		    // 对免疫灰烬的敌人只造成伤害
		    hp -= other.atk;
			event_user(0)
		    // 受伤效果
		    //effect_create_above(effect_smoke, x, y, 1, c_gray);
		} else {
		    // 直接摧毁非免疫敌人
			if special_ash{
				var inst = instance_create_depth(x,y-20,depth,obj_mouse_ash_death)
				inst.special_ash = true
				inst.sprite_index = sprite_index
				inst.image_index = image_index
			}
			else{
				instance_create_depth(x,y-20,depth,obj_mouse_ash_death)
			}
		    instance_destroy();
		    // 摧毁效果
		    //effect_create_above(ef_explosion, x, y, 1, c_yellow);
		}
	}
		
}

// 播放倭瓜攻击效果
//effect_create_above(ef_explosion, x, y, 2, c_white);

// 播放攻击声音
	global.audio.play(snd_mouse_clip_explode, 0, false);

//创建爆炸效果	 
var effect_inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
effect_inst.sprite_index = spr_skewer_bomb_effect

event_inherited()