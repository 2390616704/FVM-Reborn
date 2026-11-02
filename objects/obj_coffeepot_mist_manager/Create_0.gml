effects = [];
max_effects = 10;
depth = -520;
global.coffee_mist_mgr = id;

mgr_tex = sprite_get_texture(spr_coffeepot_mist_blob, 0);
var _uv = sprite_get_uvs(spr_coffeepot_mist_blob, 0);
mgr_u0 = _uv[0];
mgr_v0 = _uv[1];
mgr_u1 = _uv[2];
mgr_v1 = _uv[3];

mgr_emit = function(_x, _y, _len, _h, _shape, _seed) {
    if (array_length(effects) >= max_effects) return;

    var _deep = make_color_rgb(46, 15, 5);
    var _mid = make_color_rgb(199, 92, 26);
    var _cream = make_color_rgb(255, 222, 158);
    var _gold = make_color_rgb(255, 168, 64);
    var _parts = [];

    var _base_n = 24;
    for (var _i = 0; _i < _base_n; _i++) {
        var _t = (_i + random(1)) / _base_n;
        var _spread = _h * (0.12 + 0.40 * _t);
        var _col = merge_color(_mid, _cream, random_range(0.15, 0.9));
        if (random(1) < 0.25) _col = merge_color(_col, _deep, 0.35);
        var _life = irandom_range(16, 28);
        array_push(_parts, {
            x: _x + _len * _t,
            y: _y + random_range(-_spread, _spread),
            vx: random_range(0.15, 0.9),
            vy: random_range(-0.4, 0.4),
            size: random_range(24, 50) * (0.75 + 0.35 * _t),
            grow: random_range(0.15, 0.5),
            life: _life,
            max_life: _life,
            col: _col,
            alpha: random_range(0.10, 0.18),
            add: false
        });
    }

    var _glow_n = 8;
    for (var _i = 0; _i < _glow_n; _i++) {
        var _t = (_i + random(1)) / _glow_n;
        var _spread = _h * (0.06 + 0.16 * _t);
        var _life = irandom_range(12, 22);
        array_push(_parts, {
            x: _x + _len * _t,
            y: _y + random_range(-_spread, _spread),
            vx: random_range(0.2, 1.1),
            vy: random_range(-0.3, 0.3),
            size: random_range(10, 26),
            grow: random_range(0.1, 0.4),
            life: _life,
            max_life: _life,
            col: merge_color(_gold, _cream, random(1)),
            alpha: random_range(0.22, 0.40),
            add: true
        });
    }

    var _drop_n = 8;
    for (var _i = 0; _i < _drop_n; _i++) {
        var _t = (_i + random(1)) / _drop_n;
        var _life = irandom_range(8, 16);
        array_push(_parts, {
            x: _x + _len * _t,
            y: _y + random_range(-_h * 0.22, _h * 0.22),
            vx: random_range(1.2, 3.0),
            vy: random_range(-0.8, 0.8),
            size: random_range(2, 6),
            grow: 0,
            life: _life,
            max_life: _life,
            col: merge_color(_gold, _cream, random(1)),
            alpha: random_range(0.45, 0.70),
            add: true
        });
    }

    array_push(effects, {parts: _parts});
};

mgr_draw_particles = function(_add) {
    draw_primitive_begin_texture(pr_trianglelist, mgr_tex);
    for (var _e = 0; _e < array_length(effects); _e++) {
        var _parts = effects[_e].parts;
        for (var _p = 0; _p < array_length(_parts); _p++) {
            var _part = _parts[_p];
            if (_part.add != _add) continue;
            var _half = _part.size * 0.5;
            if (_part.x + _half < 0 || _part.x - _half > room_width || _part.y + _half < 0 || _part.y - _half > room_height) continue;
            var _age = _part.max_life - _part.life;
            var _a = _part.alpha * min(1, _age / 2) * min(1, _part.life / 4);
            if (_a <= 0) continue;
            var _l = _part.x - _half;
            var _r = _part.x + _half;
            var _t = _part.y - _half;
            var _b = _part.y + _half;
            draw_vertex_texture_colour(_l, _t, mgr_u0, mgr_v0, _part.col, _a);
            draw_vertex_texture_colour(_r, _t, mgr_u1, mgr_v0, _part.col, _a);
            draw_vertex_texture_colour(_l, _b, mgr_u0, mgr_v1, _part.col, _a);
            draw_vertex_texture_colour(_r, _t, mgr_u1, mgr_v0, _part.col, _a);
            draw_vertex_texture_colour(_r, _b, mgr_u1, mgr_v1, _part.col, _a);
            draw_vertex_texture_colour(_l, _b, mgr_u0, mgr_v1, _part.col, _a);
        }
    }
    draw_primitive_end();
};
