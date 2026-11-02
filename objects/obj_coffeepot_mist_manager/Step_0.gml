if (global.is_paused) exit;

for (var _e = array_length(effects) - 1; _e >= 0; _e--) {
    var _eff = effects[_e];
    var _parts = _eff.parts;
    for (var _p = array_length(_parts) - 1; _p >= 0; _p--) {
        var _part = _parts[_p];
        _part.x += _part.vx;
        _part.y += _part.vy;
        _part.vy += 0.008;
        _part.size += _part.grow;
        _part.life -= 1;
        if (_part.life <= 0) {
            array_delete(_parts, _p, 1);
        } else {
            _parts[_p] = _part;
        }
    }
    _eff.parts = _parts;
    if (array_length(_parts) == 0) {
        array_delete(effects, _e, 1);
    } else {
        effects[_e] = _eff;
    }
}
