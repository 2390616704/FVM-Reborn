#!/usr/bin/env python3
"""Generate the ignited fire-bullet and impact effect frames."""

from __future__ import annotations

import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ART = os.path.join(ROOT, "art", "fire_bullet")
S = 4
FRAMES = 8


def s(v: float) -> int:
    return int(round(v * S))


def canvas(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w * S, h * S), (0, 0, 0, 0))


def finish(img: Image.Image, w: int, h: int) -> Image.Image:
    return img.resize((w, h), Image.LANCZOS)


def polygon(draw, pts, fill, outline=None, width=1.0):
    draw.polygon([(s(x), s(y)) for x, y in pts], fill=fill)
    if outline:
        draw.line([(s(x), s(y)) for x, y in pts] + [(s(pts[0][0]), s(pts[0][1]))],
                  fill=outline, width=s(width), joint="curve")


def flame_points(phase: float, w: int, h: int):
    cy = h * 0.5
    head_x = w - 14 + 1.4 * math.sin(phase * 1.3)
    tail_x = 5 + 2.2 * math.sin(phase * 0.9 + 1.2)
    top = []
    bottom = []
    steps = 9
    for i in range(steps + 1):
        u = i / steps
        x = tail_x + (head_x - tail_x) * u
        body = math.sin(u * math.pi)
        top_y = cy - (2.0 + 5.2 * body) - 2.2 * math.sin(phase * 1.8 + u * 8.0) * body
        bot_y = cy + (2.0 + 5.2 * body) + 2.2 * math.sin(phase * 1.6 + u * 8.0 + 2.0) * body
        top.append((x, top_y))
        bottom.append((x, bot_y))
    return top, bottom


def bullet_frame(index: int) -> Image.Image:
    w, h = 82, 28
    phase = index / FRAMES * math.tau
    img = canvas(w, h)
    top, bottom = flame_points(phase, w, h)

    glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for i in range(5):
        a = 42 - i * 7
        gd.ellipse([s(10 - i), s(5 - i), s(w - 2 + i), s(h - 5 + i)],
                   fill=(255, 92, 20, max(0, a)))
    glow = glow.filter(ImageFilter.GaussianBlur(s(2.4)))
    img = Image.alpha_composite(img, glow)
    d = ImageDraw.Draw(img)

    outer = top + list(reversed(bottom))
    polygon(d, outer, (126, 24, 8, 245), (28, 6, 2, 230), 1.8)

    inner_top = []
    inner_bottom = []
    for i, (x, y) in enumerate(top):
        u = i / (len(top) - 1)
        inner_top.append((x + 2.0, y + (h * 0.5 - y) * 0.23 + 1.0))
    for i, (x, y) in enumerate(bottom):
        u = i / (len(bottom) - 1)
        inner_bottom.append((x + 2.0, y + (h * 0.5 - y) * 0.23 - 1.0))
    polygon(d, inner_top + list(reversed(inner_bottom)), (255, 103, 14, 245))

    core_top = []
    core_bottom = []
    for i, (x, y) in enumerate(top):
        u = i / (len(top) - 1)
        if u < 0.52:
            continue
        core_top.append((x + 1.0, y + (h * 0.5 - y) * 0.42 + 1.4))
    for i, (x, y) in enumerate(bottom):
        u = i / (len(bottom) - 1)
        if u < 0.52:
            continue
        core_bottom.append((x + 1.0, y + (h * 0.5 - y) * 0.42 - 1.4))
    polygon(d, core_top + list(reversed(core_bottom)), (255, 202, 58, 245))

    hx = w - 17 + 1.2 * math.sin(phase * 1.7)
    hy = h * 0.5
    d.ellipse([s(hx - 11), s(hy - 6), s(hx + 5), s(hy + 6)], fill=(255, 245, 186, 255))
    d.ellipse([s(hx - 7), s(hy - 4), s(hx + 2), s(hy + 4)], fill=(255, 255, 238, 255))

    d.line([(s(6), s(hy)), (s(26), s(hy - 1))], fill=(255, 180, 70, 120), width=s(1.2))
    d.line([(s(10), s(hy + 2)), (s(36), s(hy + 1))], fill=(255, 230, 140, 80), width=s(1))

    for i in range(7):
        u = (i + 0.5) / 7
        sx = 7 + u * 46 + math.sin(phase * 2.0 + i * 1.9) * 2.2
        sy = hy + math.sin(phase * 1.4 + i * 2.7) * (2.2 + 4.2 * u)
        r = 0.8 + 1.5 * (1 - u)
        col = (255, 186, 72, 210) if i % 3 else (255, 236, 150, 230)
        d.ellipse([s(sx - r), s(sy - r), s(sx + r), s(sy + r)], fill=col)

    if index % 2 == 0:
        smoke = Image.new("RGBA", img.size, (0, 0, 0, 0))
        sd = ImageDraw.Draw(smoke)
        for i in range(3):
            sx = 2 + i * 9 + math.sin(phase + i) * 2
            sy = hy + math.sin(phase * 1.2 + i) * 4
            sd.ellipse([s(sx - 4), s(sy - 3), s(sx + 4), s(sy + 3)],
                       fill=(72, 38, 24, 24))
        img = Image.alpha_composite(img, smoke.filter(ImageFilter.GaussianBlur(s(1.5))))

    return finish(img, w, h)


def effect_frame(index: int) -> Image.Image:
    w = h = 64
    t = index / (FRAMES - 1)
    img = canvas(w, h)
    cx = cy = 32
    radius = 7 + 21 * t
    fade = 1.0
    if t > 0.58:
        fade = max(0.0, 1.0 - (t - 0.58) / 0.42)

    glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for i in range(6):
        r = radius + 5 - i * 2
        gd.ellipse([s(cx - r), s(cy - r), s(cx + r), s(cy + r)],
                   fill=(255, 92, 18, int((42 - i * 5) * fade)))
    glow = glow.filter(ImageFilter.GaussianBlur(s(3.0)))
    img = Image.alpha_composite(img, glow)
    d = ImageDraw.Draw(img)

    def blob(r, fill, phase):
        pts = []
        for k in range(0, 360, 8):
            a = math.radians(k)
            rr = r * (0.78 + 0.14 * math.sin(a * 3 + phase) + 0.08 * math.sin(a * 7 - phase * 1.7))
            pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
        polygon(d, pts, fill)

    blob(radius + 4, (112, 24, 8, int(220 * fade)), t * 2.0)
    blob(radius * 0.78, (255, 104, 16, int(240 * fade)), t * 3.0 + 1.0)
    blob(radius * 0.48, (255, 206, 70, int(245 * fade)), t * 4.0 + 2.0)

    for i in range(12):
        ang = i / 12 * math.tau + t * 0.5
        r0 = radius * 0.42
        r1 = radius + 8 + 5 * math.sin(i * 2.1 + t * 5.0)
        base = 0.16 + 0.10 * (i % 3)
        a0 = ang - base
        a1 = ang + base
        pts = [
            (cx + math.cos(a0) * r0, cy + math.sin(a0) * r0),
            (cx + math.cos(a1) * r0, cy + math.sin(a1) * r0),
            (cx + math.cos(ang) * r1, cy + math.sin(ang) * r1)
        ]
        col = (255, 112, 20, int(210 * fade)) if i % 2 else (255, 214, 92, int(225 * fade))
        polygon(d, pts, col)

    for i in range(12):
        ang = i / 12 * math.tau + 0.37
        r = radius * (0.68 + 0.35 * math.sin(i * 3.7 + t * 7.0))
        x = cx + math.cos(ang) * r
        y = cy + math.sin(ang) * r
        rr = 1.4 + 2.4 * (1 - t)
        d.ellipse([s(x - rr), s(y - rr), s(x + rr), s(y + rr)],
                  fill=(255, 242, 166, int(225 * fade)))

    core_r = (4.5 + 9 * t) * (1.0 if t < 0.56 else max(0.25, 1.25 - t))
    d.ellipse([s(cx - core_r), s(cy - core_r), s(cx + core_r), s(cy + core_r)],
              fill=(255, 247, 205, int(255 * fade)))
    d.ellipse([s(cx - core_r * 0.55), s(cy - core_r * 0.55), s(cx + core_r * 0.55), s(cy + core_r * 0.55)],
              fill=(255, 255, 245, int(255 * fade)))

    if t > 0.45:
        smoke = Image.new("RGBA", img.size, (0, 0, 0, 0))
        sd = ImageDraw.Draw(smoke)
        for i in range(5):
            ang = i / 5 * math.tau + t
            rr = radius * 0.75
            x = cx + math.cos(ang) * rr
            y = cy + math.sin(ang) * rr
            sd.ellipse([s(x - 8), s(y - 8), s(x + 8), s(y + 8)],
                       fill=(78, 46, 36, int(58 * (t - 0.45) / 0.55)))
        img = Image.alpha_composite(img, smoke.filter(ImageFilter.GaussianBlur(s(2.4))))

    return finish(img, w, h)


def main() -> None:
    bullet_dir = os.path.join(ART, "frames", "bullet")
    effect_dir = os.path.join(ART, "frames", "effect")
    os.makedirs(bullet_dir, exist_ok=True)
    os.makedirs(effect_dir, exist_ok=True)
    for i in range(FRAMES):
        bullet_frame(i).save(os.path.join(bullet_dir, f"{i}.png"))
        effect_frame(i).save(os.path.join(effect_dir, f"{i}.png"))
    print(f"wrote {FRAMES} bullet frames and {FRAMES} effect frames to {ART}")


if __name__ == "__main__":
    main()
