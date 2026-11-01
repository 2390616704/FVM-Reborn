image_alpha = 0
image_xscale = global.grid_cell_size_x/2
image_yscale = global.grid_cell_size_y/2

var gp = get_grid_position_from_world(x, y);
row = gp.row
col = gp.col
grid_row = row
grid_col = col

hp = 3000
maxhp = 3000
target_type = "obstacle"
is_map_obstacle = true
destructible = true
damage_amount = 0
damage_type = ""
