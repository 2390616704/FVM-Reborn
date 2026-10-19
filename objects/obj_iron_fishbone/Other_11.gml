with obj_enemy_parent{
		if (hp > 0 && can_hit(other.target_type,target_type) && abs(grid_col - other.grid_col) <= 1 && abs(grid_row - other.grid_row) <= 1){
			hp -= other.atk
			event_user(0)
			audio_play_sound(snd_hit1,0,0)
			if other.shape == 2 && ice_timer < 720{
				ice_timer = 720
			}
		}
	}