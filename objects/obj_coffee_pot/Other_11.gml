var _a = degtorad(body_angle);
var _lx = spout_offset_x * body_sx;
var _ly = (spout_offset_y + upper_pivot) * body_sy;
var _pivot_y = y - upper_pivot;
var _mx = x + body_ox + _lx * cos(_a) - _ly * sin(_a);
var _my = _pivot_y + body_oy + _lx * sin(_a) + _ly * cos(_a);

recoil = 1;
muzzle_flash = 1;

var inst = instance_create_depth(_mx, _my, depth - 500, obj_coffeepot_mist);
global.audio.play(snd_coffee_pot_attack, 0, 0);
inst.damage = atk;
inst.move_speed = 0;
inst.shape = shape;
inst.row = grid_row;
inst.start_col = grid_col;
