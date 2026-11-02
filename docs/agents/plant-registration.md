# 新增植物 / 卡牌指南

面向以后新增植物、卡牌、贴图与动画的 agent / 开发者。目标：不用每次重新探索项目结构。

## 0. 速查清单

新增一个可购买、可上阵的植物，至少需要：

- [ ] 确定 `card_id`（snake_case，全项目唯一）
- [ ] `scripts/cards_init/cards_init.gml`：`register_plant_lite(...)` 注册植物数值
- [ ] `scripts/slots_init/slots_init.gml`：`register_card(...)` 注册卡牌、图标、对象
- [ ] `scripts/skill_init/skill_init.gml`：`register_card_skill(...)` **必须注册**（否则 `event_user(0)` 会崩）
- [ ] `scripts/info_island_init/info_island_init.gml`：图鉴文本
- [ ] `scripts/shop_init/shop_init.gml`：商店解锁（或调试用 `unlock_all()`）
- [ ] `objects/obj_<id>/`：对象 `.yy` + `Create_0.gml` + `Step_0.gml`（可选 `Step_2.gml`）
- [ ] `sprites/spr_<id>/`：植物精灵
- [ ] `sprites/spr_<id>_icon/`：卡面/放置预览图标
- [ ] `FVM-reborn.yyp`：`resources` + `Folders` 加入新资源
- [ ] 在 IDE 里跑通：购买 → 编队 → 放置 → 效果 → 冷却 → 存档

可选：

- [ ] `scripts/maps_init/maps_init.gml`：塔/关卡奖励形态
- [ ] `scripts/plus_card_init/plus_card_init.gml`：形态升级额外 +50 价格
- [ ] `scripts/cookbook_init/cookbook_init.gml`：食谱加成
- [ ] `scripts/attire_init/attire_init.gml`：卡牌时装
- [ ] `scripts/battle_event_init/battle_event_init.gml`：战斗事件

## 1. 心智模型

四个东西不要混：

| 概念 | 位置 | 作用 |
| --- | --- | --- |
| 植物数值 | `global.plant_registry`（`cards_init`） | 名称、描述、生命、价格、冷却、攻击等 |
| 卡牌数据 | `global.player_deck`（`slots_init`） | 图标、对象、形态、`plant_type`、放置规则 |
| 卡槽实例 | `obj_card_slot` | 本局的价格、冷却、装填数、预放置虚影 |
| 植物实例 | `obj_<id>` | 场上实体，负责自己的行为与动画 |

卡牌 ID 必须在 `cards_init`、`slots_init`、`skill_init`、`info_island_init`、商店/解锁、对象里的 `plant_id` 全部一致。

## 2. 初始化顺序

`objects/obj_game_init/Other_2.gml`：

```text
deck_init()
slots_init()          // 注册卡牌数据到 global.player_deck
skill_registry_init()
skill_init()          // 注册技能；get_plant_data_with_skill 依赖它
...
global.plant_registry = ds_map_create()
cards_init()          // 注册植物数值
...
load_file()
```

战斗内：

```text
obj_battle/Create_0.gml   -> global.default_max_charges = 3
obj_battle/Other_4.gml    -> create_battle_slots()
```

`create_battle_slots()` 从 `global.selected_deck` 读取卡牌数据并创建 `obj_card_slot`。

## 3. 数据注册

### 3.1 植物数值：`scripts/cards_init/cards_init.gml`

标准写法是 `register_plant_lite(plant_id, shapes_array)`。每个形态的数组都必须是 **17 个值**（等级 0–16）：

```gml
// 注册示例
register_plant_lite(
    "my_plant",
    [
        {
            "name": "我的植物",
            "shape": 0,
            "description": "图鉴/卡面描述",
            "hp":     [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
            "cost":   [ 50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50],
            "atk":    [ 20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20],
            "range":  [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1],
            "cooldown":[7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60],
            "cycle":  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        }
    ]
);
```

- `register_plant_lite` 会自动用同一组数组生成等级 1–16。
- 需要逐级不同数值时，直接改数组。
- 旧版 `register_plant` 只接受标量、只生成等级 0；新卡优先用 lite 版。
- 可选字段：`flame_produce`（同样是 17 个值）。

### 3.2 卡牌数据：`scripts/slots_init/slots_init.gml`

`register_card(card_id, obj, shapes_array)`：

```gml
register_card("my_plant", obj_my_plant, [
    {
        "shape": 0,
        "sprite": spr_my_plant_icon,
        "cost": 50,
        "cooldown": 7*60,
        "description": "卡面悬浮提示",
        "plant_type": "normal",
        "feature_type": "normal",
        "target_card": "none"
        // 可选：
        // "place_preview": spr_my_plant_preview,
        // "max_charges": 10,
        // "start_full": true
    }
]);
```

- `sprite` 同时是卡面图标和默认放置预览。
- `place_preview` 可单独指定放置预览。
- `max_charges` / `start_full` 是本项目为特殊卡槽加的逐卡覆盖；`create_battle_slots` 会读取。
- 多形态就写多个 `{shape: 0/1/2, ...}`。

`plant_type` 决定放置规则（见 `scripts/can_place_at_position/can_place_at_position.gml`）：

| `plant_type` | 语义 |
| --- | --- |
| `normal` | 普通植物，占格，通常不能叠放 |
| `coffee` | 浮空/咖啡类，可叠在植物上，也可放空地/障碍 |
| `lilypad` | 睡莲，只能放水面并承载植物 |
| `shield_outer` | 外层护盾，包住本格植物 |
| `player` | 玩家角色，特殊 |

常见 `feature_type`：`normal`、`water`、`amphi`、`dwarf`、`bun`、`king_bun`、`tbun`、`upgrade`。

### 3.3 技能（必须）：`scripts/skill_init/skill_init.gml`

```gml
register_card_skill("my_plant", "cooldown", [7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60,7*60]);
```

必须注册的原因：`scripts/card_skill/card_skill.gml` 的 `get_plant_data_with_skill()` 会无条件访问：

```gml
var info_id = global.skill_registry[? plant_id][0]
```

没有登记就会在植物 `event_user(0)` 时出错。数值可以不随星级变化（9 个相同值），但条目必须有。

### 3.4 图鉴：`scripts/info_island_init/info_island_init.gml`

```gml
register_card_info_island("my_plant", "基础能力：...\n *星级影响[...]，技能影响[...]。");
```

### 3.5 商店 / 解锁

`scripts/shop_init/shop_init.gml`：

```gml
register_goods("my_plant", {
    "type": "card",
    "cost": "20000",
    "unlock_item_id": "my_plant",
    "description": "商店悬浮说明",
    "display_name": "我的植物"
});
```

- 购买时 `obj_shop_buy_confirm` 会调用 `unlock_card(target_item, 0, 0, max_skill_level)`。
- 调试用一键解锁在 `objects/obj_game_init/Other_2.gml` 的 `unlock_all()` 里加一行。
- 塔/关卡奖励在 `scripts/maps_init/maps_init.gml` 的 `rewards` 列表里加 `{card_id, target_shape}`。

## 4. 植物对象

新建 `objects/obj_<id>/`，父对象设为 `obj_card_parent`。

### 4.1 `Create_0.gml`

```gml
event_inherited();
plant_id = "my_plant";
obj_type = object_index;
current_level = 1;
event_user(0);              // 必须：按存档等级/形态/技能初始化 hp/cost/cooldown...
sprite_index = spr_my_plant;

attack_anim = 8;
attack_timer = 0;
idle_anim = 8;
flash_speed = 8;
plant_type = "normal";
is_slowdown = false;
current_hp = hp;
```

`event_user(0)` 对应父对象的 `Other_10.gml`，它会：

- 从 `global.plant_registry` 读名称/描述
- 从 `get_card_info(plant_id)` 读等级/形态/技能
- 调 `get_plant_data_with_skill()` 写入 hp / max_hp / cost / atk / range / cooldown / cycle
- 应用食谱加成
- 设置 `plant_type` / `feature_type` / `target_card`

所以：**先设 `plant_id`，再调 `event_user(0)`**。运行时如果要改价格/冷却，必须发生在这次初始化之后（通常是卡槽的 Step，或植物首帧）。

### 4.2 `Step_0.gml`

```gml
if global.is_paused { exit }

event_inherited();

var current_flash_speed = flash_speed;
if is_slowdown { current_flash_speed *= 2; }

attack_timer++;

if attack_timer == 1 {
    // 首次生效：做效果
}

if attack_timer > current_flash_speed * idle_anim - 1 {
    instance_destroy();
}
```

- 父对象 `Step_0.gml` 已经负责网格坐标、深度、状态、动画帧推进。
- 子对象的 Step 里调 `event_inherited()` 后，再写自己的逻辑。
- 一次性辅助植物常用 `attack_timer == 1` 触发，`attack_timer` 超过寿命自毁。

### 4.3 常见“作用于同格其他植物”的写法

```gml
with (obj_card_parent) {
    if (plant_id != "player" && plant_id != "my_plant") {
        if (grid_row == other.grid_row && grid_col == other.grid_col) {
            with (obj_card_slot) {
                if (card_id == other.plant_id) {
                    // 在这里改目标卡槽
                }
            }
        }
    }
}
```

`other` 在嵌套 `with` 里分别指向上一层实例：外层 `other` 是植物自己，内层 `other` 是目标植物。不要把 `other` 当成卡槽。

### 4.4 `Step_2.gml`（可选）

需要免疫冰冻/减速时，像 `obj_ice_cream` 一样：

```gml
ice_timer = 0;
frozen_timer = 0;
```

## 5. 卡槽生命周期（改价格/冷却/装填必读）

`objects/obj_card_slot/Create_0.gml` 默认值：

```text
cooldown = 7*60
cooldown_timer = 30000
max_charges = global.default_max_charges   // 3
charges = 1
reloading = false
startup_reload_pending = true
```

`create_battle_slots()` 覆盖：

- `cost` / `cooldown` / `card_obj` / `card_spr` / `place_preview`
- `description` / `slot_index` / `card_id` / `shape`
- 可选：`max_charges`、`start_full`

第一次 Step 末尾会执行 `event_user(0)`（`Other_10.gml`），从植物数值 + 技能 + 食谱重新写 `cost` / `cooldown`。**不要在 `create_battle_slots` 里做会被它覆盖的持久化修改**。

卡槽方法：

| 方法 | 作用 |
| --- | --- |
| `consume_charge()` | 消耗 1 发；需要时开始补弹 |
| `materialize_one_pending_ghost()` | 把 1 发花在队首预放置虚影上；失败会退款/移除 |
| `advance_reload(frames)` | 把冷却推进 N 帧，可跨多个装填周期；每装一发会尝试实体化一个虚影 |

自然补弹在 `obj_card_slot/Step_0.gml`：`cooldown_timer` 到达 `cooldown` 后 `charges++`，然后处理虚影。

`max_charges` / `start_full` 示例（咖啡豆）：

```gml
{"shape":0, ..., "max_charges":10, "start_full":true}
```

`start_full` 会设置 `charges = max_charges`、`reloading = false`、`startup_reload_pending = false`、`cooldown_timer = cooldown`。

## 6. 贴图与动画

### 6.1 现有尺寸参考

| 资源 | 尺寸 | 帧数 | 原点 |
| --- | --- | --- | --- |
| `spr_coffee_grounds` | 74×98 | 13 | 自定义 (39,73) |
| `spr_ice_cream` | 100×132 | 16 | 底部中心 |
| `spr_coffee_bean` | 72×92 | 8 | 底部中心 (36,92) |
| `spr_coffee_grounds_icon` | 74×98 | 1 | 自定义 |
| `spr_ice_cream_icon` | 91×120 | 1 | 自定义 (45,95) |
| `spr_coffee_bean_icon` | 91×120 | 1 | 自定义 (45,95) |

植物精灵通常 72–100 px 宽；卡面图标通常 74–91 px 宽、98–120 px 高。网格单元约 107×116。

### 6.2 GameMaker 精灵目录结构

```text
sprites/spr_<id>/
├── spr_<id>.yy
├── <frame-uuid-1>.png
├── <frame-uuid-2>.png
├── ...
└── layers/
    ├── <frame-uuid-1>/
    │   └── <layer-uuid>.png
    └── <frame-uuid-2>/
        └── <layer-uuid>.png
```

- 根目录每帧一张 PNG。
- `layers/<frame-uuid>/<layer-uuid>.png` 是该帧的图层合成图；单图层项目里通常和根目录那张相同。
- `.yy` 的 `frames`、`layers`、`sequence.tracks[0].keyframes` 必须引用这些 UUID。

`.yy` 关键字段：

- `width` / `height`：最终显示尺寸
- `frames`：每帧 UUID
- `layers`：图层 UUID
- `sequence.length`：帧数
- `sequence.tracks[0].keyframes`：`Key` 0..N-1，`Channels.0.Id` 指向帧 UUID + 本 sprite 的 `.yy` 路径
- `origin`：`7` = 底部中心，`9` = 自定义（配合 `sequence.xorigin/yorigin`）
- `sequence.xorigin/yorigin`：原点像素坐标
- `textureGroupId`：植物用 `cards`，卡面/UI 用 `UI`
- `edgeFiltering: false`、`preMultiplyAlpha: false`

> GameMaker IDE 打开项目后可能重写 `.yy`：加入尾逗号、重算 bbox、重存 PNG。以 IDE 保存后的格式为准；脚本生成的严格 JSON 也能被 IDE 读取。

### 6.3 动画契约

父对象 `obj_card_parent/Create_0.gml` 设置 `image_speed = 0`，由 `obj_card_parent/Step_0.gml` 手动推进 `image_index`：

```text
timer < flash_speed-1 -> timer++
否则 -> image_index++（到 idle_anim 后回 0），timer=0
```

所以：

- `flash_speed` = 每帧停留多少个游戏步（60 步/秒）
- `idle_anim` = 帧数（通常等于精灵帧数）
- 寿命常用 `attack_timer > flash_speed * idle_anim - 1`
- `attack_anim` 只在 `CARD_STATE.ATTACK` 用到
- 精灵 `.yy` 里的 `playbackSpeed` 在 `image_speed=0` 时基本不生效，保持合理值即可

例：8 帧、`flash_speed=8` → 每帧约 0.13 秒，总寿命约 1.07 秒。

### 6.4 平滑/卡通管线（当前咖啡豆用的）

适合非像素风、圆润描边：

1. 用 Pillow 在 4× 画布上绘制（超采样）。
2. 旋转、渐变、描边、模糊都在 4× 空间做。
3. 最后 `resize((w,h), Image.LANCZOS)` 下采样。
4. 每帧导出根 PNG + `layers/<frame>/<layer>.png`。
5. 写 `.yy`，加入 `.yyp`。

优点：边缘平滑、适合渐变和半透明特效。缺点：帧数多时生成慢；不适合严格像素对齐。

### 6.5 像素风管线（复杂特效推荐）

适合想画小尺寸、特效多、风格统一的植物：

1. **先定原生网格**：16 / 24 / 32 / 48 / 64。不要中途改。
2. **整数倍放大到显示尺寸**，例如：
   - 16×16 → 96×96（6×）
   - 24×24 → 96×96（4×）
   - 32×32 → 96×96（3×）
   - 48×48 → 96×96（2×）
3. 用 `Image.NEAREST` 放大，**不要**用 LANCZOS/BICUBIC。
4. 限色板（建议 12–24 色），1 px 深色描边，1 px 高光；不要抗锯齿。
5. 精灵最终尺寸 = 原生尺寸 × 整数倍；游戏内不要用小数 `image_xscale/yscale`，不要旋转像素精灵（预旋转好每一帧）。
6. `.yy` 保持 `edgeFiltering: false`、`preMultiplyAlpha: false`。
7. 特效不要全烘进角色帧：角色只画本体，火焰/闪电/冲击波/粒子用独立 effect 对象（见 6.6）。
8. 帧数可以少一些，用 `flash_speed` 调整节奏；例如 6 帧 × 10 步 ≈ 1 秒。

像素风生成骨架：

```python
from PIL import Image

native = Image.open("art/my_plant_0.png").convert("RGBA")   # 32x32
scale = 3
final = native.resize((native.width * scale, native.height * scale), Image.NEAREST)
final.save("frame.png")
# 然后把 frame.png 同时写入：
#   sprites/spr_my_plant/<frame-uuid>.png
#   sprites/spr_my_plant/layers/<frame-uuid>/<layer-uuid>.png
```

> 关键：最终 `.yy` 的 `width/height` 写放大后的尺寸，而不是原生 32×32。

### 6.5.1 用 `tools/build_sprite_resource.py` 打包

仓库里有现成工具，负责把源帧打包成 GameMaker 精灵目录结构并生成 `.yy`，同时打印需要粘到 `.yyp` 的行。它不负责画图。依赖 Pillow（当前环境已安装）。

源帧命名：`0.png..N-1.png` 或 `frame_0.png..frame_N-1.png`。

```powershell
# 像素风：32x32 原生帧，3x NEAREST 放大到 96x96
python tools/build_sprite_resource.py --name spr_my_plant `
  --src art/my_plant --frames 8 --pixel-scale 3 `
  --origin bottom --texture-group cards `
  --folder "folders/精灵/Cards/Assistant/my_plant" --overwrite

# 平滑风：源帧已经是最终尺寸（pixel-scale 1）
python tools/build_sprite_resource.py --name spr_my_plant_icon `
  --src art/my_plant_icon --frames 1 --pixel-scale 1 `
  --origin custom --origin-x 45 --origin-y 95 --texture-group UI `
  --folder "folders/精灵/Cards/Assistant/my_plant" --overwrite
```

- `--overwrite` 会先删掉旧的 `sprites/spr_<name>/`，避免残留旧帧。
- `--origin bottom` 自动用底部中心；`--origin custom` 需要 `--origin-x/--origin-y`。
- 植物用 `--texture-group cards`；卡面图标用 `UI`。
- 工具会输出 `.yyp` 的 `resources` 行和 `Folders` 行，复制粘贴即可。

> 如果以后想批量做像素风，建议把原生帧按 `art/<plant>/0.png..` 放好，再跑这个工具；不要手工拼 UUID 和 layers 目录。

### 6.6 复杂特效怎么做

优先复用现有 effect 对象，而不是把每一帧都画进植物精灵：

- 火焰/燃烧：`obj_flame`、`obj_burn_effect`、`obj_large_fire`、`obj_small_fire`
- 放置/入水：`obj_place_effect`、`obj_in_water_effect`
- 冰冻/减速：`obj_ice_residue`、`obj_unfreeze_effect`
- 睡眠/唤醒：`obj_sleep_effect`
- 闪屏/震屏：`obj_screen_flash_manager`、`obj_rumble`
- 闪电：`obj_lightning_baguette_thunder`、`obj_vajra_lightning`

做法：

1. 植物 Step 在合适时机 `instance_create_depth(x, y, depth, obj_xxx_effect)`。
2. 特效对象自己负责生命周期/帧动画/混合模式。
3. 像素风特效也用“原生网格 + NEAREST 放大”，但可以比角色更小、更亮。
4. 需要叠加发光时用加法混合（`gpu_set_blendmode(bm_add)`），画完恢复 `bm_normal`。
5. 深度用 `calculate_plant_depth(col, row, plant_type)` 或在其基础上 ± 偏移。

这样复杂特效不会把植物精灵撑得很大，也方便单独调色/复用。

### 6.7 加入 `.yyp`

在 `FVM-reborn.yyp` 的 `resources` 里加：

```json
{"id":{"name":"obj_my_plant","path":"objects/obj_my_plant/obj_my_plant.yy",},},
{"id":{"name":"spr_my_plant","path":"sprites/spr_my_plant/spr_my_plant.yy",},},
{"id":{"name":"spr_my_plant_icon","path":"sprites/spr_my_plant_icon/spr_my_plant_icon.yy",},},
```

新文件夹还要在 `Folders` 里加一条（例如放在 Assistant 下）：

```json
{"$GMFolder":"","%Name":"my_plant","folderPath":"folders/精灵/Cards/Assistant/my_plant.yy","name":"my_plant","resourceType":"GMFolder","resourceVersion":"2.0",},
```

`.yyp` 带尾逗号，不是严格 JSON。改完可以用下面命令做结构校验：

```powershell
python -c "import re,json; s=open('FVM-reborn.yyp',encoding='utf-8-sig').read(); json.loads(re.sub(r',\s*([}\]])', r'\1', s))"
```

### 6.8 生成/清理注意事项

- 重新生成精灵前，先删掉旧的 `sprites/spr_<id>/`（或给 `tools/build_sprite_resource.py` 加 `--overwrite`），否则会留下未引用的旧帧 PNG。
- `.yy` 里的帧 UUID、keyframe UUID、layer UUID 必须互相对应，且 PNG 文件名 = 帧 UUID。
- 卡面图标建议单独做 1 帧，不要把 8 帧植物精灵直接当卡面。
- 植物原点优先“底部中心”；卡面图标用自定义原点对齐卡框（参考冰激凌/咖啡豆的 (45,95)）。
- IDE 保存后 `.yy` 会变成带尾逗号的格式，并可能重算 bbox/重存 PNG；这是正常的，不要用严格 JSON 校验 `.yy`。

## 7. 测试清单

在 IDE 里跑（当前环境没有可用的命令行构建）：

- [ ] 商店能买到 / `unlock_all()` 能解锁
- [ ] 卡组里能看到，图标和价格正确
- [ ] 放置到空地、障碍、水面、已有植物上符合 `plant_type` 规则
- [ ] 目标卡槽已满 / 正在冷却 / 有预放置虚影 三种情况都试
- [ ] 价格、冷却、装填数显示正确
- [ ] 植物自毁/死亡后能从网格移除
- [ ] 存档退出再进不崩（`event_user(0)` / 技能注册）
- [ ] 精灵原点、大小、动画速度符合预期

静态检查：

```powershell
# GML 大括号/圆括号平衡（粗略）
# .yyp 结构
python -c "import re,json; s=open('FVM-reborn.yyp',encoding='utf-8-sig').read(); json.loads(re.sub(r',\s*([}\]])', r'\1', s))"
```

## 8. 常见坑

- **没注册技能**：`get_plant_data_with_skill()` 直接索引 `global.skill_registry[? plant_id][0]`，会崩。
- **`register_plant_lite` 数组长度不是 17**：升级等级会越界。
- **在 `create_battle_slots` 里改 cost/cooldown**：第一次 Step 的 `Other_10` 会覆盖。
- **`event_user(0)` 之前没设 `plant_id`**：读到空 ID。
- **嵌套 `with` 里误用 `other`**：内层 `other` 是上一层实例，不是卡槽。
- **精灵帧 UUID 与 PNG 文件名不一致**：游戏里会缺帧/报错。
- **重新生成不清理旧帧**：目录里堆未引用 PNG。
- **像素画用了 LANCZOS 或小数缩放**：会糊。
- **咖啡/浮空植物忘了 `plant_type: "coffee"`**：无法叠放。
- **新卡 ID 只改了一半文件**：商店有、卡组没有，或对象 `plant_id` 对不上。

## 9. 现成样例：`coffee_bean`

| 内容 | 文件 |
| --- | --- |
| 植物数值 | `scripts/cards_init/cards_init.gml`（搜索 `coffee_bean`） |
| 卡牌数据 | `scripts/slots_init/slots_init.gml` |
| 技能占位 | `scripts/skill_init/skill_init.gml` |
| 图鉴 | `scripts/info_island_init/info_island_init.gml` |
| 商店 | `scripts/shop_init/shop_init.gml` |
| 调试解锁 | `objects/obj_game_init/Other_2.gml` |
| 对象 | `objects/obj_coffee_bean/` |
| 植物精灵 | `sprites/spr_coffee_bean/` |
| 卡面图标 | `sprites/spr_coffee_bean_icon/` |
| 多装填/推进冷却 | `objects/obj_card_slot/Create_0.gml` 的 `advance_reload()` |
| 同格目标写法 | `objects/obj_coffee_bean/Step_0.gml` |

咖啡豆当前规则：

- 自身冷却固定 7 秒，开局 10 发
- 每次使用自身价格 +25（本局内）
- 对同格植物（排除玩家与咖啡豆自身）推进 30 秒冷却
- 目标冷却 < 30 秒时可能连续装填多发；每装一发会尝试实体化一个预放置虚影

## 10. 相关文档

- `AGENTS.md`：agent 入口
- `docs/agents/domain.md`：领域文档 / ADR 约定
- `docs/agents/issue-tracker.md`：本地 issue 约定
- `CONTEXT.md`：如果后续创建，用它统一“浮空植物 / 装填 / 冷却推进 / 预放置”等术语

## 11. 快速定位现有卡牌与特效

按卡牌 id 定位，不要先全局搜特效名：

1. `scripts/slots_init/slots_init.gml`：搜 `register_card("<id>", obj_<id>, ...)`，确认对象、卡面图标、放置预览。
2. `scripts/cards_init/cards_init.gml`：确认数值与形态注册。
3. `objects/obj_<id>/`：看 `Create_0.gml` 的默认值、`Step_0.gml` 的索敌/攻击节奏。
4. `objects/obj_<id>/Other_11.gml`：通常是攻击触发点（User Event 1），从这里找 `instance_create_depth(...)` 生成子弹/特效。
5. `objects/obj_..._bullet/` 或 `objects/obj_..._effect/`：看伤害、生命周期、碰撞和绘制。
6. `sprites/spr_...`：确认是逐帧动画、单图、还是需要替换成共享贴图/合批特效。
7. 如果子弹复用了共享对象，检查 `sprite_index` 覆盖；视觉资源可能不在当前卡牌目录下。

替换喷射/子弹特效时，先保留原伤害与生命周期接口，再替换视觉资源或新增合批特效层；不要先改数值逻辑。最后用 Igor 编译并在游戏内验收。

## 12. 文档导航

- `AGENTS.md`：agent 全局规范、美术/特效注册流程
- `docs/agents/plant-registration.md`：卡牌注册与现有卡牌/特效定位
- `docs/agents/issue-tracker.md`：issue 约定
- `docs/agents/triage-labels.md`：triage 标签
- `docs/agents/domain.md`：domain 文档 / ADR 约定
