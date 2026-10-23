// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
	sprite_index = spr_pope_mouse
}

event_inherited();



if global.is_paused || is_frozen || is_stun{
	exit
}
if state != ENEMY_STATE.DEAD{
	if perform_timer < perform_cooldown{
		perform_timer++
	}
	else{
		if state != ENEMY_STATE.ACTING{
			timer = 0
			state = ENEMY_STATE.ACTING
			sprite_index = spr_pope_mouse_perform
		}
	}

	if state = ENEMY_STATE.ACTING{
		if hp > maxhp*hurt_rate{
			image_index = floor(timer/flash_speed) mod 15
		}
		else{
			image_index = floor(timer/flash_speed) mod 16 + 15
		}
		if timer == flash_speed * 31 - 1{
			var _heal_targets = []
			var _healer_x = x
			var _healer_y = y
			with obj_enemy_parent{
				if hp > 0 && hp < maxhp{
					array_push(_heal_targets, {
						inst: id,
						rate: hp / maxhp,
						dist: point_distance(x, y, _healer_x, _healer_y),
						order: array_length(_heal_targets)
					})
				}
			}
			array_sort(_heal_targets, function(_a, _b){
				if _a.rate != _b.rate{
					return _a.rate - _b.rate
				}
				if _a.dist != _b.dist{
					return _a.dist - _b.dist
				}
				return _a.order - _b.order
			})
			var _heal_count = min(10, array_length(_heal_targets))
			for (var i = 0; i < _heal_count; i++){
				var _target = _heal_targets[i].inst
				if !instance_exists(_target) continue
				if _target.maxhp < 600{
					_target.maxhp = 600
				}
				if _target.hp <= _target.maxhp - 600{
					_target.hp += 600
				}
				else{
					_target.hp = _target.maxhp
				}
				var _effect = instance_create_depth(_target.x, _target.y - 45, _target.depth - 1, obj_card_heal_effect)
				_effect.sprite_index = spr_mouse_heal_effect
			}
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_pope_mouse
			timer = 0
			perform_timer = 0
		}
	}
}