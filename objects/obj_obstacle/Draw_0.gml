if (!is_map_obstacle) exit;
if (hp <= 0 || hp >= maxhp) exit;

var gp = get_world_position_from_grid(grid_col, grid_row);
var bx = gp.x - 34;
var by = gp.y - 82;
var bw = 68;
var bh = 7;

draw_set_alpha(0.85);
draw_rectangle_colour(bx - 1, by - 1, bx + bw + 1, by + bh + 1, c_black, c_black, c_black, c_black, false);
var ratio = clamp(hp / maxhp, 0, 1);
draw_rectangle_colour(bx, by, bx + bw * ratio, by + bh, c_fuchsia, c_aqua, c_fuchsia, c_aqua, false);
draw_set_alpha(1);
