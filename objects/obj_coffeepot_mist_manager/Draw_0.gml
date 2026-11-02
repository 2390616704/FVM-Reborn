if (array_length(effects) <= 0) exit;

gpu_set_blendmode(bm_normal);
mgr_draw_particles(false);

gpu_set_blendmode(bm_add);
mgr_draw_particles(true);

gpu_set_blendmode(bm_normal);
