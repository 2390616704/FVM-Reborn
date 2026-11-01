if (global.is_paused) exit;
if (!instance_exists(owner)) { instance_destroy(); exit; }

if (!is_array(sparks)) sparks = [];
depth = owner.depth - 500;
visual_time += 1;
for (var _si = array_length(sparks) - 1; _si >= 0; _si--) {
    var _sp = sparks[_si];
    _sp.px = _sp.x;
    _sp.py = _sp.y;
    _sp.x += _sp.vx;
    _sp.y += _sp.vy;
    _sp.vy += 0.04;
    _sp.life -= 1;
    if (_sp.life <= 0) {
        array_delete(sparks, _si, 1);
    } else {
        sparks[_si] = _sp;
    }
}

if (owner.is_frozen) {
    intensity = 0;
    exit;
}

if (instance_exists(target)) {
    var valid = (target.hp > 0);
    if (valid && !in_owner_range(target)) valid = false;
    if (valid && !can_target_on(beam_target_type(), target.target_type)) valid = false;
    if (!valid) target = noone;
}

if (target == noone) {
    target = acquire_target();
    if (target != noone) {
        lock_frames = 0;
        tick_timer = 0;
        tick_index = 0;
    }
}

if (target != noone) {
    lock_frames += 1;
    tick_timer += 1;
    if (tick_timer >= 30) {
        tick_timer -= 30;
        tick_index += 1;
        apply_tick_damage();
    }
    intensity = 0.3 + 0.7 * power(min(lock_frames / 300, 1), 1.5);
} else {
    lock_frames = 0;
    tick_timer = 0;
    tick_index = 0;
    intensity = 0;
}

if (target != noone && instance_exists(target)) {
    var _sx = target.x + irandom_range(-9, 9);
    var _sy = target.y - 20 + irandom_range(-9, 9);
    var _ang = random(360);
    var _spd = random_range(0.8, 2.4);
    var _sp = {
        x: _sx, y: _sy, px: _sx, py: _sy,
        vx: lengthdir_x(_spd, _ang),
        vy: lengthdir_y(_spd, _ang) - 0.5,
        life: irandom_range(10, 18),
        max_life: 0,
        size: random_range(0.8, 2.0)
    };
    _sp.max_life = _sp.life;
    array_push(sparks, _sp);
    if (array_length(sparks) > 48) array_delete(sparks, 0, 1);
}
