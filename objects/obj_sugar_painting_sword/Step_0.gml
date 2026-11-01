if global.is_paused {
    exit;
}

event_inherited();

// 冰冻 / 睡眠：收回飞出的剑刃，恢复完整剑
if (state == CARD_STATE.SLEEP || is_frozen) {
    if (instance_exists(blade_inst)) {
        instance_destroy(blade_inst);
        blade_inst = noone;
    }
    if (sprite_index != full_sprite) {
        sprite_index = full_sprite;
        idle_anim = 5;
        image_index = 0;
    }
    exit;
}

// 剑刃还在飞：本体等待
if (instance_exists(blade_inst)) exit;

// 剑刃刚结束：恢复完整剑，立即找下一个目标
if (blade_inst != noone) {
    blade_inst = noone;
    sprite_index = full_sprite;
    idle_anim = 5;
    image_index = 0;
}

// 找目标格：左右各 6 格、±2 行、取最左
var _best_col = 999999;
var _best_row = -1;
var _best_rd = 999999;
var _best_x = 999999;
var _pcol = grid_col;
var _prow = grid_row;
var _prange = col_range;
var _lrange = left_range;
var _rrange = row_range;
var _ptype = target_type;

with (obj_enemy_parent) {
    if (hp <= 0 || y <= 0) continue;
    if (grid_col < _pcol - _lrange) continue;
    if (grid_col > _pcol + _prange) continue;
    if (abs(grid_row - _prow) > _rrange) continue;
    if (!can_target_on(_ptype, target_type)) continue;

    var _rd = abs(grid_row - _prow);
    if (grid_col < _best_col ||
        (grid_col == _best_col && (_rd < _best_rd ||
         (_rd == _best_rd && x < _best_x)))) {
        _best_col = grid_col;
        _best_row = grid_row;
        _best_rd = _rd;
        _best_x = x;
    }
}

if (_best_row < 0) exit;

var _B = get_world_position_from_grid(_best_col, _best_row);
var _inst = instance_create_depth(x, y, depth, obj_sugar_sword_blade);
_inst.owner = id;
_inst.shape = shape;
_inst.home_x = x;
_inst.home_y = y;
_inst.target_x = _B.x;
_inst.target_y = _B.y;
_inst.atk = atk;
_inst.target_type = target_type;
_inst.damage_type = damage_type;
_inst.hit_radius = hit_radius;
_inst.blade_offset = blade_offset;
_inst.travel_speed = travel_speed;
_inst.sprite_index = spr_sugar_sword_blade;
if shape == 1 _inst.sprite_index = spr_sugar_sword_blade_1;
if shape == 2 _inst.sprite_index = spr_sugar_sword_blade_2;
_inst.image_angle = 0;

blade_inst = _inst;
sprite_index = hilt_sprite;
idle_anim = 0;
image_index = 0;
exit;
