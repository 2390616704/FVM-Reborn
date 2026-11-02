effects = [];
max_effects = 14;
depth = -521;
global.oden_spray_mgr = id;

fx_tex = sprite_get_texture(spr_coffeepot_mist_blob, 0);
var _uv = sprite_get_uvs(spr_coffeepot_mist_blob, 0);
fx_u0 = _uv[0];
fx_v0 = _uv[1];
fx_u1 = _uv[2];
fx_v1 = _uv[3];

mgr_spawn_line = function(_x, _y, _angle, _len, _wid, _style, _seed) {
    if (array_length(effects) >= max_effects) return;

    var _parts = [];
    var _count = (_style == 2) ? 48 : 32;
    for (var _i = 0; _i < _count; _i++) {
        var _t = (_i + random(1)) / _count;
        var _perp = random_range(-1, 1) * _wid * 0.5 * (0.35 + 0.65 * _t);
        var _px = _x + lengthdir_x(_len * _t, _angle) + lengthdir_x(_perp, _angle + 90);
        var _py = _y + lengthdir_y(_len * _t, _angle) + lengthdir_y(_perp, _angle + 90);
        var _spd = random_range(0.3, 1.6);
        var _life = irandom_range(16, 28);
        var _col;
        if (_style == 2) {
            _col = merge_color(make_color_rgb(150, 28, 14), make_color_rgb(255, 205, 82), random(1));
        } else {
            _col = merge_color(make_color_rgb(122, 72, 24), make_color_rgb(255, 225, 160), random(1));
        }
        array_push(_parts, {
            x: _px,
            y: _py,
            vx: lengthdir_x(_spd, _angle) + random_range(-0.35, 0.35),
            vy: lengthdir_y(_spd, _angle) + random_range(-0.35, 0.35),
            size: random_range(14, 34) * (0.8 + 0.4 * _t),
            grow: random_range(0.08, 0.32),
            life: _life,
            max_life: _life,
            col: _col,
            alpha: random_range(0.10, 0.20),
            add: false
        });
    }

    var _glow = (_style == 2) ? 14 : 10;
    for (var _i = 0; _i < _glow; _i++) {
        var _t = (_i + random(1)) / _glow;
        var _perp = random_range(-1, 1) * _wid * 0.24 * (0.3 + 0.7 * _t);
        var _px = _x + lengthdir_x(_len * _t, _angle) + lengthdir_x(_perp, _angle + 90);
        var _py = _y + lengthdir_y(_len * _t, _angle) + lengthdir_y(_perp, _angle + 90);
        var _life = irandom_range(10, 20);
        var _col = (_style == 2)
            ? merge_color(make_color_rgb(255, 84, 24), make_color_rgb(255, 240, 170), random(1))
            : merge_color(make_color_rgb(220, 150, 60), make_color_rgb(255, 245, 200), random(1));
        array_push(_parts, {
            x: _px,
            y: _py,
            vx: lengthdir_x(random_range(0.4, 1.8), _angle) + random_range(-0.3, 0.3),
            vy: lengthdir_y(random_range(0.4, 1.8), _angle) + random_range(-0.3, 0.3),
            size: random_range(8, 22),
            grow: random_range(0.08, 0.28),
            life: _life,
            max_life: _life,
            col: _col,
            alpha: random_range(0.22, 0.42),
            add: true
        });
    }

    array_push(effects, {parts: _parts});
};

mgr_spawn_burst = function(_x, _y, _rad, _style, _seed) {
    if (array_length(effects) >= max_effects) return;

    var _parts = [];
    var _count = 64;
    for (var _i = 0; _i < _count; _i++) {
        var _ang = random(360);
        var _dist = sqrt(random(1)) * _rad;
        var _life = irandom_range(16, 30);
        var _col = merge_color(make_color_rgb(150, 28, 14), make_color_rgb(255, 210, 90), random(1));
        array_push(_parts, {
            x: _x + lengthdir_x(_dist, _ang),
            y: _y + lengthdir_y(_dist, _ang),
            vx: lengthdir_x(random_range(0.2, 1.3), _ang),
            vy: lengthdir_y(random_range(0.2, 1.3), _ang),
            size: random_range(16, 44) * (0.7 + 0.6 * (_dist / _rad)),
            grow: random_range(0.06, 0.3),
            life: _life,
            max_life: _life,
            col: _col,
            alpha: random_range(0.10, 0.20),
            add: false
        });
    }
    for (var _i = 0; _i < 20; _i++) {
        var _ang = random(360);
        var _dist = sqrt(random(1)) * _rad * 0.75;
        var _life = irandom_range(10, 20);
        array_push(_parts, {
            x: _x + lengthdir_x(_dist, _ang),
            y: _y + lengthdir_y(_dist, _ang),
            vx: lengthdir_x(random_range(0.3, 1.8), _ang),
            vy: lengthdir_y(random_range(0.3, 1.8), _ang),
            size: random_range(8, 24),
            grow: random_range(0.08, 0.3),
            life: _life,
            max_life: _life,
            col: merge_color(make_color_rgb(255, 84, 24), make_color_rgb(255, 242, 170), random(1)),
            alpha: random_range(0.20, 0.40),
            add: true
        });
    }
    array_push(effects, {parts: _parts});
};

mgr_draw_particles = function(_add) {
    draw_primitive_begin_texture(pr_trianglelist, fx_tex);
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
            draw_vertex_texture_colour(_l, _t, fx_u0, fx_v0, _part.col, _a);
            draw_vertex_texture_colour(_r, _t, fx_u1, fx_v0, _part.col, _a);
            draw_vertex_texture_colour(_l, _b, fx_u0, fx_v1, _part.col, _a);
            draw_vertex_texture_colour(_r, _t, fx_u1, fx_v0, _part.col, _a);
            draw_vertex_texture_colour(_r, _b, fx_u1, fx_v1, _part.col, _a);
            draw_vertex_texture_colour(_l, _b, fx_u0, fx_v1, _part.col, _a);
        }
    }
    draw_primitive_end();
};
