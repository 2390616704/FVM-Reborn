if global.is_paused{
	exit
}



if hp <= 0.33*max_hp{
	sprite_index = sprite_list[2]
}
else if hp <= 0.66*max_hp{
	sprite_index = sprite_list[1]
}
else{
	sprite_index = sprite_list[0]
}
event_inherited();

if is_frozen{
	exit
}

current_hp = hp
if frozen_timer > 0{
	exit
}

if instance_exists(inner_inst){
	inner_inst.depth = depth + 2
}
