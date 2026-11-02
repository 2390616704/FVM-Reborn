image_xscale = 1;
image_yscale = 1;

if (instance_exists(banding_star_obj)) {
    banding_star_obj.depth = depth - 1;
}

var frame = clamp(shape, 0, 2);
var tint = is_slowdown ? merge_color(c_white, c_blue, 0.5) : c_white;
var draw_x = x + body_ox;
var draw_y = y - upper_pivot + body_oy;

draw_sprite_ext(spr_coffee_pot_liquid, frame, draw_x, draw_y + liquid_oy, body_sx, body_sy, body_angle, tint, 1);
draw_sprite_ext(spr_coffee_pot_body, frame, draw_x, draw_y, body_sx, body_sy, body_angle, tint, 1);
draw_sprite_ext(spr_coffee_pot_base, frame, x, y, 1, 1, 0, tint, 1);
draw_sprite_ext(spr_coffee_pot_lid, frame, draw_x, draw_y + lid_offset, body_sx, body_sy, body_angle, tint, 1);
draw_sprite_ext(spr_coffee_pot_face, face_index, draw_x, draw_y, body_sx, body_sy, body_angle, tint, 1);

if (muzzle_flash > 0) {
    var flash_angle = degtorad(body_angle);
    var flash_c = cos(flash_angle);
    var flash_s = sin(flash_angle);
    var anchor_x = 70 * body_sx;
    var anchor_y = -41 * body_sy;
    var muzzle_x = draw_x + anchor_x * flash_c - anchor_y * flash_s;
    var muzzle_y = draw_y + anchor_x * flash_s + anchor_y * flash_c;

    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.35 + 0.55 * muzzle_flash);
    draw_circle_colour(muzzle_x, muzzle_y, 12 + 14 * muzzle_flash, c_white, c_orange, false);
    draw_set_alpha(0.55 + 0.45 * muzzle_flash);
    draw_circle_colour(muzzle_x, muzzle_y, 5 + 7 * muzzle_flash, c_white, c_yellow, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

if (flash_value > 0) {
    var flash_alpha = clamp(flash_value / 200, 0, 1);
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(spr_coffee_pot_body, frame, draw_x, draw_y, body_sx, body_sy, body_angle, c_white, flash_alpha);
    draw_sprite_ext(spr_coffee_pot_lid, frame, draw_x, draw_y + lid_offset, body_sx, body_sy, body_angle, c_white, flash_alpha);
    draw_sprite_ext(spr_coffee_pot_face, face_index, draw_x, draw_y, body_sx, body_sy, body_angle, c_white, flash_alpha);
    gpu_set_blendmode(bm_normal);
}

if is_frozen {
    draw_sprite_ext(spr_mouse_frozen, 0, x, y + 95, 1.8, 1.8, 0, c_white, 1);
}
