if global.is_paused {
    exit;
}

event_inherited();

if is_frozen {
    exit;
}

var current_flash_speed = flash_speed;
if is_slowdown {
    current_flash_speed *= 2;
}

if shape < 1 {
    if state == CARD_STATE.AWAKE {
        wake_timer++;
        if wake_timer >= 5 * current_flash_speed {
            state = CARD_STATE.IDLE;
            timer = 0;
        }
    }
}

var has_enemy = false;
if shape < 2 {
    with (obj_enemy_parent) {
        if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (other.grid_col + 4) && can_target_on(other.target_type, target_type)) {
            has_enemy = true;
            break;
        }
    }
} else {
    with (obj_enemy_parent) {
        if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type, target_type)) {
            has_enemy = true;
            break;
        }
    }
}

if state != CARD_STATE.SLEEP && state != CARD_STATE.AWAKE {
    if (has_enemy) {
        if (attack_timer <= cycle - attack_anim * current_flash_speed) {
            attack_timer++;
        } else if (attack_timer == cycle - (attack_anim - 3) * current_flash_speed && state == CARD_STATE.ATTACK) {
            attack_timer++;
            event_user(1);
        } else if (attack_timer <= cycle) {
            attack_timer++;
            state = CARD_STATE.ATTACK;
        } else {
            attack_timer = 0;
            state = CARD_STATE.IDLE;
        }
    } else {
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
}

visual_time += 1;

recoil = max(0, recoil - 0.075);
muzzle_flash = max(0, muzzle_flash - 0.14);

var breath = sin(visual_time * 0.05 + breath_phase);
var attack_target = (state == CARD_STATE.ATTACK) ? 1 : 0;
var sleep_target = (state == CARD_STATE.SLEEP) ? 1 : 0;

attack_visual = lerp(attack_visual, attack_target, 0.24);
sleep_visual = lerp(sleep_visual, sleep_target, 0.08);

var jelly = sin(visual_time * 0.38) * 3.2 * recoil;

body_angle = 1.0 * sin(visual_time * 0.023 + breath_phase) + 5.5 * attack_visual - 12.0 * recoil + jelly - 2.8 * sleep_visual;
body_sx = 1 + 0.022 * breath - 0.025 * attack_visual + 0.040 * recoil + 0.010 * sleep_visual;
body_sy = 1 + 0.040 * breath + 0.055 * attack_visual - 0.045 * recoil - 0.022 * sleep_visual;
body_ox = 3.5 * attack_visual - 10.0 * recoil - 1.2 * sleep_visual;
body_oy = 1.4 * sin(visual_time * 0.070 + breath_phase) - 3.0 * attack_visual - 3.5 * recoil + 1.8 * sleep_visual;

lid_offset = -1.4 * sin(visual_time * 0.090 + breath_phase * 0.7) - 2.5 * attack_visual - 5.0 * recoil + 2.0 * sleep_visual;
liquid_angle = 0;
liquid_ox = 0;
liquid_oy = 0.6 * sin(visual_time * 0.080 + breath_phase * 0.5);

if (sleep_visual > 0.5) {
    face_index = 3;
} else if (attack_visual > 0.5) {
    face_index = 2;
} else {
    face_index = (shape >= 2) ? 2 : ((shape == 1) ? 1 : 0);
}
