flash_value = 150

var _is_transferred = variable_instance_exists(id, "ghost_transfer_damage") && ghost_transfer_damage;
var _has_ghost_aura = false;
with (obj_ghost_mouse) {
	if (hp > 0 && id != other.id &&
		abs(grid_row - other.grid_row) <= 1 &&
		abs(grid_col - other.grid_col) <= 1) {
		_has_ghost_aura = true;
	}
}
if (_has_ghost_aura) {
	damage_amount *= 0.75;
}

if (!_is_transferred && mouse_id == "ghost_mouse") {
	var _recipients = [];
	with (obj_enemy_parent) {
		if (hp > 0 && id != other.id && grid_row == other.grid_row) {
			array_push(_recipients, id);
		}
	}
	if (array_length(_recipients) > 0) {
		var _share = damage_amount * 0.9 / array_length(_recipients);
		damage_amount *= 0.1;
		for (var i = 0; i < array_length(_recipients); i++) {
			var _receiver = _recipients[i];
			if (!instance_exists(_receiver)) continue;
			_receiver.ghost_transfer_damage = true;
			_receiver.damage_amount = _share;
			_receiver.damage_type = damage_type;
			with (_receiver) event_user(0);
			_receiver.ghost_transfer_damage = false;
		}
	}
}

if shield_hp > 0{
	if damage_type == "normal"{
		shield_hp -= damage_amount
	}
	else if damage_type == "pierce"{
		shield_hp -= damage_amount
		hp -= damage_amount
	}
	else {
		hp -= damage_amount
	}
}
else{
	hp -= damage_amount
}