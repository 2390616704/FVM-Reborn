var _t = fx_time + timer;
var _back = 62 + 26 * shape;
var _n = 20;
var _fade = image_alpha;

gpu_set_blendmode(bm_add);
draw_primitive_begin_texture(pr_trianglelist, fx_tex);

for (var _i = 0; _i < _n; _i++) {
    var _u = _i / _n;
    var _px = x - _back * _u + sin(_t * 0.13 + _i * 1.7) * (5 + 7 * _u);
    var _py = y + sin(_t * 0.21 + _i * 0.9) * (4 + 10 * _u) + (8 - 16 * _u) * _u;
    var _half = (22 + 2 * shape) * (1 - 0.62 * _u) * 0.5;
    var _a = _fade * (0.28 - 0.18 * _u);
    var _col = merge_color(make_color_rgb(255, 92, 26), make_color_rgb(255, 226, 130), _u);
    if (shape >= 2) _col = merge_color(_col, make_color_rgb(255, 48, 18), 0.25);

    draw_vertex_texture_colour(_px - _half, _py - _half, fx_u0, fx_v0, _col, _a);
    draw_vertex_texture_colour(_px + _half, _py - _half, fx_u1, fx_v0, _col, _a);
    draw_vertex_texture_colour(_px - _half, _py + _half, fx_u0, fx_v1, _col, _a);
    draw_vertex_texture_colour(_px + _half, _py - _half, fx_u1, fx_v0, _col, _a);
    draw_vertex_texture_colour(_px + _half, _py + _half, fx_u1, fx_v1, _col, _a);
    draw_vertex_texture_colour(_px - _half, _py + _half, fx_u0, fx_v1, _col, _a);
}

draw_primitive_end();

var _core = 6 + shape * 2 + sin(_t * 0.3) * 1.5;
draw_set_alpha(_fade * 0.65);
draw_circle_colour(x, y, _core * 1.8, make_color_rgb(255, 74, 20), make_color_rgb(255, 216, 110), false);
draw_set_alpha(_fade);
draw_circle_colour(x, y, _core, c_white, make_color_rgb(255, 170, 60), false);
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
