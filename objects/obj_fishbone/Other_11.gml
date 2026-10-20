var stunned_any = false;
with obj_enemy_parent{
	if (hp > 0 && abs(grid_col - other.grid_col) <= 1 && abs(grid_row - other.grid_row) <= 1) {
		if (stun_timer < 300) stun_timer = 300;
		stun_sprite = spr_mouse_stick;
		stunned_any = true;
	}
}
is_used = true;
state = CARD_STATE.ATTACK;
if (stunned_any) audio_play_sound(snd_hit1,0,0);