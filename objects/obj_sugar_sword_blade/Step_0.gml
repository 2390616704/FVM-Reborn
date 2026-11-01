if global.is_paused {
    exit;
}

if (!instance_exists(owner)) {
    instance_destroy();
    exit;
}
if (owner.state == CARD_STATE.SLEEP || owner.is_frozen) {
    instance_destroy();
    exit;
}

if (!path_built) {
    // 以植物位置和目标格中心为直径的圆
    var _Ax = home_x;
    var _Ay = home_y;
    var _Bx = target_x;
    var _By = target_y;
    var _dist = point_distance(_Ax, _Ay, _Bx, _By);
    if (_dist < 1) {
        _Bx = _Ax + global.grid_cell_size_x;
        _By = _Ay;
        _dist = global.grid_cell_size_x;
    }

    var _ux = (_Bx - _Ax) / _dist;
    var _uy = (_By - _Ay) / _dist;
    var _px = -_uy;
    var _py = _ux;
    // 起手切线向上
    if (_py > 0) {
        _px = -_px;
        _py = -_py;
    }

    var _a = _dist * 0.5;
    var _b = _dist * 0.5;
    var _cx = (_Ax + _Bx) * 0.5;
    var _cy = (_Ay + _By) * 0.5;
    var _N = 128;

    path_x = array_create(_N + 1, 0);
    path_y = array_create(_N + 1, 0);
    path_cum = array_create(_N + 1, 0);
    path_cum[0] = 0;

    for (var i = 0; i <= _N; i++) {
        var _t = 2 * pi * i / _N;
        path_x[i] = _cx - _a * cos(_t) * _ux + _b * sin(_t) * _px;
        path_y[i] = _cy - _a * cos(_t) * _uy + _b * sin(_t) * _py;
        if (i > 0) {
            path_cum[i] = path_cum[i - 1] +
                point_distance(path_x[i - 1], path_y[i - 1],
                               path_x[i], path_y[i]);
        }
    }

    var _half = _N div 2;
    path_half = path_cum[_half];
    path_len = path_cum[_N];
    path_pos = 0;
    hit_list = [];
    swing_state = 1;
    path_built = true;
}

var _step = travel_speed / 60;
if (owner.is_slowdown) _step *= 0.5;
path_pos += _step;

// 到达目标格，开始回程；命中集合不重置，每次挥击每个敌人只打一次
if (swing_state == 1 && path_pos >= path_half) {
    swing_state = 2;
}

if (path_pos >= path_len) {
    instance_destroy();
    exit;
}

// 沿折线按弧长插值
var _pos = clamp(path_pos, 0, path_len);
var _idx = 0;
while (_idx < array_length(path_cum) - 2 && path_cum[_idx + 1] < _pos) {
    _idx++;
}
var _seg = max(1, path_cum[_idx + 1] - path_cum[_idx]);
var _f = (_pos - path_cum[_idx]) / _seg;
x = lerp(path_x[_idx], path_x[_idx + 1], _f);
y = lerp(path_y[_idx], path_y[_idx + 1], _f);

var _ang = point_direction(path_x[_idx], path_y[_idx],
                           path_x[_idx + 1], path_y[_idx + 1]);
image_angle = _ang - 90;

// 剑身中心（命中圆）
hit_x = x + lengthdir_x(blade_offset, _ang);
hit_y = y + lengthdir_y(blade_offset, _ang);

// 深度按当前所在格重算
var _gp = get_grid_position_from_world(x, y);
var _dc = clamp(_gp.col, 0, global.grid_cols - 1);
var _dr = clamp(_gp.row, 0, global.grid_rows - 1);
depth = calculate_plant_depth(_dc, _dr, "normal") - 1;

// 命中：去程 / 回程各自一次
var _hx = hit_x;
var _hy = hit_y;
with (obj_enemy_parent) {
    if (hp <= 0) continue;
    if (!can_hit(other.target_type, target_type)) continue;
    if (array_get_index(other.hit_list, id) != -1) continue;
    if (point_distance(x, y, _hx, _hy) > other.hit_radius) continue;

    var _hl = other.hit_list;
    array_push(_hl, id);
    other.hit_list = _hl;

    damage_amount = other.atk;
    damage_type = other.damage_type;
    event_user(0);
}
