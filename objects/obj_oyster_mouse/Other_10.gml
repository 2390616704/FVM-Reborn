flash_value = 150
var _guardian_damage = damage_type != "throw" ? 0.1 * damage_amount : damage_amount
if (enemy_guardian_try_transfer(id, _guardian_damage, damage_type)) {
	damage_amount = 0
	damage_type = ""
	exit
}
if damage_type != "throw"{
	hp -= 0.1*damage_amount
}
else{
	hp -= damage_amount
}
damage_amount = 0
damage_type = ""