if (!instance_exists(owner)) exit;

if (target == noone || !instance_exists(target) || owner.is_frozen) exit;

var ox = owner.x;
var oy = owner.y + owner.orb_offset_y;
var tx = target.x;
var ty = target_hit_y(target);
var len = point_distance(ox, oy, tx, ty);
if (len < 1) exit;
var ang = point_direction(ox, oy, tx, ty);
var wid = 6 + 18 * intensity;

shader_set(shd_ice_beam);
var u_time = shader_get_uniform(shd_ice_beam, "u_time");
var u_intensity = shader_get_uniform(shd_ice_beam, "u_intensity");
var u_core = shader_get_uniform(shd_ice_beam, "u_core");
var u_glow = shader_get_uniform(shd_ice_beam, "u_glow");
var u_edge = shader_get_uniform(shd_ice_beam, "u_edge");
shader_set_uniform_f(u_time, visual_time / 60);
shader_set_uniform_f(u_intensity, intensity);

gpu_set_blendmode(bm_normal);
shader_set_uniform_f(u_core, 0.04, 0.14, 0.20, 1.0);
shader_set_uniform_f(u_glow, 0.02, 0.07, 0.11, 1.0);
shader_set_uniform_f(u_edge, 0.02, 0.09, 0.14, 1.0);
draw_sprite_ext(spr_ice_beam_quad, 0, ox, oy, len / 2, wid * 0.65, ang, c_white, 0.22);

shader_set_uniform_f(u_core, 1.0, 1.0, 1.0, 1.0);
shader_set_uniform_f(u_glow, 0.35, 0.88, 1.0, 1.0);
shader_set_uniform_f(u_edge, 0.82, 0.30, 1.0, 1.0);

gpu_set_blendmode(bm_add);
draw_sprite_ext(spr_ice_beam_quad, 0, ox, oy, len / 2, wid * 0.9, ang, c_white, 0.45);
draw_sprite_ext(spr_ice_beam_quad, 0, ox, oy, len / 2, wid * 0.5, ang, c_white, 1);
gpu_set_blendmode(bm_normal);
shader_reset();

gpu_set_blendmode(bm_add);
var spark_n = 2 + floor(6 * intensity);
for (var i = 0; i < spark_n; i++) {
    var t = frac(visual_time * 0.017 + i * 0.37);
    var sx = lerp(ox, tx, t);
    var sy = lerp(oy, ty, t);
    var sr = 1.2 + 2.5 * intensity;
    var _taper = clamp(t / 0.06, 0, 1) * clamp((1 - t) / 0.20, 0, 1);
    draw_set_alpha((0.25 + 0.55 * intensity) * _taper);
    draw_circle_colour(sx, sy, sr, c_white, c_aqua, false);
}
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);

gpu_set_blendmode(bm_add);
var ix = target.x;
var iy = ty;
var core_r = 2.5 + 3.5 * intensity;
draw_set_alpha(0.55 + 0.35 * intensity);
draw_circle_colour(ix, iy, core_r, c_white, c_aqua, false);
draw_set_alpha(0.20 + 0.25 * intensity);
draw_circle_colour(ix, iy, core_r * 2.4, c_aqua, c_fuchsia, false);
if ((visual_time mod 2) == 0) {
    draw_set_alpha(0.35 + 0.35 * intensity);
    draw_circle_colour(ix + irandom_range(-2, 2), iy + irandom_range(-2, 2), core_r * 1.4, c_white, c_white, false);
}
if (!is_array(sparks)) sparks = [];
for (var _i = 0; _i < array_length(sparks); _i++) {
    var _sp = sparks[_i];
    var _a = _sp.life / _sp.max_life;
    draw_set_alpha(0.25 + 0.65 * _a);
    draw_set_colour(merge_color(c_aqua, c_white, _a));
    draw_line_width(_sp.px, _sp.py, _sp.x, _sp.y, max(1, _sp.size));
    draw_circle_colour(_sp.x, _sp.y, _sp.size, c_white, c_aqua, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);
gpu_set_blendmode(bm_normal);
