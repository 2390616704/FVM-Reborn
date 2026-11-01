var s = 1.8;
var t = beam_visual_time;
var bx = x;
var by = y - 8;
var bob = sin(t * 0.035) * 2;
var ox = x;
var oy = y + orb_offset_y + bob;
var orb_spr = spr_ice_ball_cup_orb;
if (shape == 1) orb_spr = spr_ice_ball_cup_orb_1;
if (shape == 2) orb_spr = spr_ice_ball_cup_orb_2;

var pulse = 1 + 0.06 * sin(t * 0.12) + 0.10 * charge_visual;
var tint = is_slowdown ? merge_color(c_white, c_blue, 0.5) : c_white;

if (instance_exists(banding_star_obj)) banding_star_obj.depth = depth - 1;

// ground shadow
draw_set_alpha(0.20);
draw_ellipse_colour(bx - 26, by - 5, bx + 26, by + 5, c_black, c_black, false);
draw_set_alpha(1);

gpu_set_blendmode(bm_add);

// living base pool
var lp = 0.5 + 0.5 * sin(t * 0.09);
draw_set_alpha((0.10 + 0.16 * charge_visual) * (0.70 + 0.30 * lp));
draw_ellipse_colour(bx - 30, by - 9, bx + 30, by + 9, c_aqua, c_fuchsia, false);
draw_set_alpha((0.08 + 0.12 * charge_visual) * (0.60 + 0.40 * lp));
draw_ellipse_colour(bx - 20, by - 6, bx + 20, by + 6, c_fuchsia, c_aqua, false);

// rotating base rings
draw_sprite_ext(spr_ice_ball_cup_ring, 0, bx, by, s * 0.55, s * 0.28, t * 0.50, c_aqua, 0.28 + 0.22 * charge_visual);
draw_sprite_ext(spr_ice_ball_cup_ring, 0, bx, by, s * 0.42, s * 0.20, -t * 0.80 + 30, c_fuchsia, 0.22 + 0.18 * charge_visual);

// ground runes / spokes
for (var i = 0; i < 6; i++) {
    var a = degtorad(t * 0.90 + i * 60);
    var r0 = 12;
    var r1 = 24 + 8 * charge_visual;
    draw_set_colour(merge_color(c_aqua, c_fuchsia, 0.15));
    draw_set_alpha(0.12 + 0.18 * charge_visual);
    draw_line_width(bx + cos(a) * r0, by + sin(a) * r0 * 0.35,
                    bx + cos(a) * r1, by + sin(a) * r1 * 0.35, 2);
}
draw_set_alpha(1);
draw_set_colour(c_white);

// energy column from base to orb
draw_primitive_begin(pr_trianglelist);
draw_vertex_colour(bx - 14, by - 2, c_aqua, 0.08 + 0.10 * charge_visual);
draw_vertex_colour(bx + 14, by - 2, c_aqua, 0.08 + 0.10 * charge_visual);
draw_vertex_colour(ox, oy, c_fuchsia, 0.08 + 0.10 * charge_visual);
draw_primitive_end();

draw_set_alpha(0.10 + 0.14 * charge_visual);
draw_set_colour(c_aqua);
draw_line_width(bx, by - 2, ox, oy, 2);
draw_set_alpha(1);
draw_set_colour(c_white);

// rising motes from base to orb
for (var i = 0; i < 10; i++) {
    var u = frac(t * 0.008 + i * 0.13);
    var mx = bx + sin(t * 0.02 + i * 2.1) * (10 + 12 * (1 - u));
    var my = by - u * (by - (oy + 6));
    draw_set_alpha((1 - u) * 0.24);
    draw_circle_colour(mx, my, 1.0 + 1.6 * charge_visual, c_white, c_aqua, false);
}
draw_set_alpha(1);

// orb
gpu_set_blendmode(bm_add);
draw_sprite_ext(orb_spr, 0, ox, oy, s * 0.60 * pulse, s * 0.60 * pulse, 0, tint, 0.10 + 0.22 * charge_visual);
gpu_set_blendmode(bm_normal);
draw_sprite_ext(orb_spr, 0, ox, oy, s * 0.50 * pulse, s * 0.50 * pulse, t * 0.5, tint, 1);

// floating rings
gpu_set_blendmode(bm_add);
var ring_col = merge_color(c_aqua, c_fuchsia, 0.20);
draw_sprite_ext(spr_ice_ball_cup_ring, 0, ox, oy, s * 0.45, s * 0.30, t * 0.70, ring_col, 0.28 + 0.22 * charge_visual);
draw_sprite_ext(spr_ice_ball_cup_ring, 0, ox, oy, s * 0.36, s * 0.24, -t * 0.90 + 35, ring_col, 0.22 + 0.22 * charge_visual);
if (shape >= 2) {
    draw_sprite_ext(spr_ice_ball_cup_ring, 0, ox, oy, s * 0.55, s * 0.22, t * 0.50 + 70, c_fuchsia, 0.18 + 0.18 * charge_visual);
}
if (charge_visual > 0.01) {
    draw_set_alpha(0.06 + 0.16 * charge_visual);
    draw_circle_colour(ox, oy, 10 + 10 * charge_visual, c_aqua, c_fuchsia, false);
    draw_set_alpha(1);
}
gpu_set_blendmode(bm_normal);

if (air_beam_count > 0) {
    draw_sprite_ext(spr_ice_ball_cup_aa_lens, 0, ox + 5, oy - 20, s * 0.45, s * 0.45, t * 1.2, c_white, 1);
}

// hit flash / frozen
if (flash_value > 0) {
    gpu_set_blendmode(bm_add);
    draw_set_alpha(flash_value / 250);
    draw_circle_colour(ox, oy, 26 + 8 * charge_visual, c_white, c_white, false);
    draw_circle_colour(bx, by, 24, c_white, c_white, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

if (is_frozen) {
    draw_sprite_ext(spr_mouse_frozen, 0, x, y + 95, 1.8, 1.8, 0, c_white, 1);
}
