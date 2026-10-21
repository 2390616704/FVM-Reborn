enemy_type_list = []
boss_type_list = []

feedback_text = ""
feedback_timer = 0

random_buttons = [
    { x: 640, y: 1025, scale: 0.9, label: "刷新普通敌人", action: "enemies", hover: false, pressed: false },
    { x: 960, y: 1025, scale: 0.9, label: "刷新Boss", action: "boss", hover: false, pressed: false },
    { x: 1280, y: 1025, scale: 0.9, label: "刷新地图", action: "map", hover: false, pressed: false },
    { x: 1600, y: 85, scale: 0.75, label: "保存模板", action: "save", hover: false, pressed: false },
    { x: 1800, y: 85, scale: 0.75, label: "加载模板", action: "load", hover: false, pressed: false }
]

mouse_preview_inst = []