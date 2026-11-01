# 冰球杯（ice_ball_cup）实现 Spec

状态：ready-for-agent
来源：与用户的 grill 设计讨论

## 1. 身份

- 卡 ID：`ice_ball_cup`
- 0★：冰球杯
- 1★：幻彩冰球杯
- 2★：棱镜冰球杯
- 解锁：普通商店，20000 金币
- 造型：白瓷/玻璃高脚杯，场上杯体 56×84（不占两行），冰球半径为原方案的一半，
  两道光环，底座品红光环；白/金/青/品红。2★ 杯口展开 4 瓣，球体上方多一个对空浮环。
  不绘制 4 根约束臂。

## 2. 数值

| 项 | 值 |
|---|---|
| cost | 300 |
| cooldown | 420 帧（7 秒） |
| HP | 400（三形态一致） |
| range | 3（以自身为中心 7×7） |
| atk（满蓄力单跳） | `[30,36,42,48,54,60,66,78,96,120,165,210,255,300,345,390,435]` |
| tick | 30 帧（0.5 秒） |
| ramp | `m = 0.3 + 0.7 * pow(min(t/5,1), 1.5)`；5 秒到 100%，之后保持 |
| 目标 | 当前 HP 最大优先（含障碍）；锁定后不主动换；同血量列小优先；不可叠同一目标 |

## 3. 光束

| 形态 | 总光束 | 通用 | 专用对空 | 通用类型 |
|---|---:|---:|---:|---|
| 0★ | 4 | 4 | 0 | `normal`（普通+障碍） |
| 1★ | 5 | 4 | 1 | `normal`（普通+障碍） |
| 2★ | 6 | 5 | 1 | `all`（全部） |

- 通用光束 0★/1★ 不能打空中；1★ 的空中能力只来自专用对空光束。
- 对空光束 `air_only`，只锁 `target_type == "air"`。
- 目标不足时多余光束待机，不叠同一目标。
- 只锁 7×7（row ±3、col ±3）内的目标。

## 4. 障碍

- `obj_obstacle`：`hp=3000`、`maxhp=3000`、`target_type="obstacle"`、`destructible=true`、`is_map_obstacle=true`。
- 地图障碍加细血条；不做受击闪白。
- 激光对地图障碍伤害 ×3；`obj_barrier` / `obj_angelababy_diamond` 不加成。
- 障碍死亡：`grid_terrains[row][col].type = (global.row_feature[row]=="water" ? "water" : "normal")`，销毁自身。
- 删除 `obj_event_manager/Step_0.gml` 里生成 `obj_obstacle` 的那批隐形阻挡。
- `obj_barrier`、`obj_angelababy_diamond`：HP 10000 → 3000。
- 动态地形标记（`obj_platform`、洞穴、管道等）不处理：激光锁不到。

## 5. 视觉

- 杯体/冰球/光环/命中爆点用贴图；光束用 `shd_ice_beam` Shader 程序化。
- 分层程序化动画：冰球缩放/脉冲；光环旋转；主体 `flash_speed=2`（30 FPS）或静态。
- 光束 Shader：白热核心 + 青色内焰 + 品红外焰，加法混合；ramp 驱动粗细、
  亮度、颜色、流速；5 秒满蓄力加冲击环 + 轻微屏震。
- 命中：保留 6 帧加法爆点，但以每 2 帧一次的高频小爆点绘制，尺寸随机、偏移随机，
  类似焊接“滋滋滋”；敌人自身的受击闪光仍然保留。
- 2★ 对空浮环作为专用对空光束发射点。

## 6. 文件清单

新增：

- `objects/obj_ice_ball_cup/`（Create/Step/Draw/Destroy + .yy）
- `objects/obj_ice_ball_cup_beam/`（Create/Step/Draw + .yy）
- `objects/obj_ice_ball_cup_impact/`（Create/Step + .yy）可选，先直接画
- `shaders/shd_ice_beam/`（.yy/.vsh/.fsh）
- `sprites/spr_ice_ball_cup*`、`spr_ice_ball_cup_icon*`、
  `spr_ice_ball_cup_orb`、`spr_ice_ball_cup_ring`、`spr_ice_ball_cup_impact`、
  `spr_ice_beam_quad`

修改：

- `scripts/cards_init/cards_init.gml`
- `scripts/slots_init/slots_init.gml`
- `scripts/skill_init/skill_init.gml`
- `scripts/info_island_init/info_island_init.gml`
- `scripts/shop_init/shop_init.gml`
- `objects/obj_game_init/Other_2.gml`（unlock_all）
- `objects/obj_obstacle/Create_0.gml`、`Step_0.gml`、`Draw_0.gml`、`Destroy_0.gml`
- `objects/obj_barrier/Create_0.gml`
- `objects/obj_angelababy_diamond/Create_0.gml`
- `objects/obj_event_manager/Step_0.gml`（删除隐形障碍生成）
- `FVM-reborn.yyp`

## 7. 测试

- 商店能买；卡组显示；放置/冷却/存档正常。
- 0★ 4 束只打地面；1★ 4 地面 + 1 对空；2★ 5 全类型 + 1 对空。
- 7×7 中心索敌；最高 HP 优先；不叠同一目标；锁定不换。
- ramp：0.5s 一跳，5s 到最大；光束变粗变亮。
- 地图障碍 3000 HP、血条、×3、破坏后格子可种；隐形阻挡已删。
- barrier/diamond 3000 HP，无 ×3。
- 静态检查 `.yyp` 结构。
