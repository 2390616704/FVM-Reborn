## Agent skills

### 文档导航

- 卡牌/植物注册与现有卡牌/特效定位：`docs/agents/plant-registration.md`
- Issue 约定：`docs/agents/issue-tracker.md`
- Triage 标签：`docs/agents/triage-labels.md`
- Domain 文档/ADR：`docs/agents/domain.md`
- 美术/特效规范：见下方 `### 美术与特效约定`

### Issue tracker

Issues and PRDs are tracked as local markdown under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles, using their default strings: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` at the repo root and ADRs under `docs/adr/`. See `docs/agents/domain.md`.

### Plant and card registration

When adding or modifying a plant or card, read `docs/agents/plant-registration.md` first. It lists every registration point, the card-slot lifecycle, and the sprite/animation pipelines (including pixel art and separate effect objects).

### 美术与特效约定

- 新增或重做美术资源/特效时，默认采用混合方案：共享贴图（或图集）+ 合批的粒子/程序化几何；每种混合模式 1-2 次 draw call，并限制同时存在的特效数量。
- 常见特效不要使用逐实例 draw call，也不要在 CPU 上逐顶点做噪声计算。
- “合批几何”是性能预算，不强制所有东西都画成四边形：粒子默认用带贴图四边形；圆形、环形、弧形等按形状选择少量专用几何；主体允许使用分层贴图/图集。
- 卡牌本体优先使用**连续时间驱动**（`sin`/`lerp`/弹簧），不要用低帧率逐帧序列。
- 注意 `obj_card_parent` 当前把卡牌精灵按 **1.8 倍**绘制。新卡牌资源应按最终显示尺寸制作，或在对象上显式使用 1:1 绘制，避免低分辨率源图被放大。
- SVG 只用于内部预览/源文件，不进入游戏包；最终导出 PNG/图集。验收以游戏内效果为准。

### 美术与特效注册

1. 源图按最终显示尺寸制作；需要多帧或多图层时，拆成独立 PNG。
2. 用 `tools/build_sprite_resource.py` 生成 `sprites/spr_<name>/`，指定 origin、texture group 和 folder。
3. 把资源行加入 `FVM-reborn.yyp`；新文件夹同步加入 Folders。
4. 在对象/卡牌中引用；卡牌还需更新注册点，见 `docs/agents/plant-registration.md`。
5. 用 Igor 编译，并在游戏内验收；不要只靠 IDE 静态预览判断动画。
