if (is_map_obstacle && grid_row >= 0 && grid_row < global.grid_rows && grid_col >= 0 && grid_col < global.grid_cols) {
    global.grid_terrains[grid_row][grid_col].type = (global.row_feature[grid_row] == "water") ? "water" : "normal";
}
