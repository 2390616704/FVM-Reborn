#!/usr/bin/env python3
"""Generate the animated flame currency sprites.

Outputs:
  art/flame/frames/normal/0..9.png  (98x98, used by spr_flame)
  art/flame/frames/small/0..9.png   (76x76, used by spr_flame_small)

The collectible is a glowing ember orb with a layered, time-driven flame core.
Frames are rendered at 4x and downsampled for clean anti-aliased edges.
"""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "art" / "flame" / "frames"
FRAMES = 10
SS = 4


def smoothstep(edge0: float, edge1: float, x):
    t = np.clip((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def mix(a, b, t):
    return a + (b - a) * t


def over(dst: np.ndarray, src_rgb: np.ndarray, src_a: np.ndarray):
    a = np.clip(src_a, 0.0, 1.0)[..., None]
    dst[..., :3] = src_rgb * a + dst[..., :3] * (1.0 - a)
    dst[..., 3:4] = src_a[..., None] + dst[..., 3:4] * (1.0 - a)
    return dst


def flame_polygon(size: int, base_y: float, tip_y: float, width: float,
                  sway: float, phase: float, wobble: float = 1.0,
                  base_x: float = 0.0):
    n = 80
    left = []
    right = []
    for i in range(n + 1):
        t = i / n
        y = base_y + (tip_y - base_y) * t
        centre = base_x + sway * math.sin(math.pi * 1.35 * t + phase) * (t ** 1.1)
        centre += 0.018 * math.sin(6.0 * math.pi * t + phase * 1.7) * t * wobble
        half = width * ((1.0 - t) ** 0.62)
        half *= 1.0 + 0.07 * math.sin(5.0 * math.pi * t + phase) * wobble
        if t > 0.94:
            half *= max(0.0, (1.0 - t) / 0.06)
        left.append((centre - half, y))
        right.append((centre + half, y))
    pts = left + list(reversed(right))
    return [((x + 1.0) * 0.5 * size, (y + 1.0) * 0.5 * size) for x, y in pts]


def mask_from_polygon(size: int, points) -> np.ndarray:
    im = Image.new("L", (size, size), 0)
    ImageDraw.Draw(im).polygon(points, fill=255)
    return np.asarray(im, dtype=np.float32) / 255.0


def flame_rgba(size: int, mask: np.ndarray, tip_rgb, base_rgb, alpha: float):
    yy = np.linspace(-1.0, 1.0, size, dtype=np.float32)[:, None]
    # Approximate vertical gradient: tip is cool red, base is hot yellow.
    t = np.clip((yy + 0.72) / 0.95, 0.0, 1.0)
    rgb = np.zeros((size, size, 3), dtype=np.float32)
    for c in range(3):
        rgb[..., c] = mix(tip_rgb[c], base_rgb[c], t)
    return rgb, mask * alpha


def add_flame(canvas, mask, tip_rgb, base_rgb, alpha, blur=0.0):
    if blur > 0:
        im = Image.fromarray((np.clip(mask, 0, 1) * 255).astype(np.uint8), "L")
        im = im.filter(ImageFilter.GaussianBlur(blur))
        mask = np.asarray(im, dtype=np.float32) / 255.0
    rgb, a = flame_rgba(canvas.shape[0], mask, tip_rgb, base_rgb, alpha)
    over(canvas, rgb, a)


def render(size: int, frame: int) -> Image.Image:
    s = size * SS
    phase = 2.0 * math.pi * frame / FRAMES
    pulse = 1.0 + 0.018 * math.sin(phase * 2.0)
    bob = 0.008 * math.sin(phase)

    yy, xx = np.mgrid[0:s, 0:s].astype(np.float32)
    x = (xx + 0.5) / s * 2.0 - 1.0
    y = (yy + 0.5) / s * 2.0 - 1.0 - bob
    r = np.sqrt(x * x + y * y)

    canvas = np.zeros((s, s, 4), dtype=np.float32)

    # Soft outer aura.
    glow = 0.42 * np.exp(-((r / 0.86) ** 2) ** 1.25)
    glow += 0.20 * np.exp(-((r / 0.62) ** 2) ** 2.0)
    glow = np.clip(glow, 0.0, 0.62)
    glow_t = np.clip(r / 0.9, 0.0, 1.0)
    glow_rgb = np.zeros((s, s, 3), dtype=np.float32)
    glow_inner = (255, 205, 95)
    glow_outer = (255, 62, 6)
    for c in range(3):
        glow_rgb[..., c] = mix(glow_inner[c], glow_outer[c], glow_t)
    over(canvas, glow_rgb, glow)

    r0 = 0.69 * pulse
    sphere_alpha = 1.0 - smoothstep(r0 - 0.018, r0 + 0.018, r)
    sphere_alpha *= smoothstep(0.0, 0.02, sphere_alpha)

    # Sphere body: dark red rim -> orange -> hot amber core.
    d = np.clip(r / r0, 0.0, 1.0)
    body = np.zeros((s, s, 3), dtype=np.float32)
    stops = [
        (0.00, (255, 228, 132)),
        (0.35, (255, 174, 52)),
        (0.66, (245, 92, 14)),
        (0.88, (205, 40, 6)),
        (1.00, (150, 22, 4)),
    ]
    for i in range(len(stops) - 1):
        t0, c0 = stops[i]
        t1, c1 = stops[i + 1]
        m = (d >= t0) & (d <= t1)
        if not np.any(m):
            continue
        k = np.clip((d - t0) / (t1 - t0), 0.0, 1.0)
        for c in range(3):
            body[..., c][m] = mix(c0[c], c1[c], k[m])
    light = np.clip(0.52 - 0.58 * x - 0.62 * y, 0.0, 1.0)
    body += (255, 235, 170) * (0.20 * light[..., None])
    body *= (0.88 + 0.12 * np.clip((y + 0.6) / 1.4, 0.0, 1.0))[..., None]
    over(canvas, np.clip(body, 0, 255), sphere_alpha)

    # Warm rim and a cool-hot inner edge.
    rim = np.exp(-((r - (r0 - 0.025)) / 0.030) ** 2)
    rim *= sphere_alpha
    over(canvas, np.array([255, 155, 45], dtype=np.float32), rim * 0.55)
    inner_rim = np.exp(-((r - (r0 - 0.085)) / 0.042) ** 2)
    inner_rim *= sphere_alpha * 0.35
    over(canvas, np.array([255, 220, 90], dtype=np.float32), inner_rim)

    # A hot, dark ember bed keeps the flame readable against the glowing orb.
    ember_bed = np.exp(-(((x - 0.01) / 0.48) ** 2 +
                         ((y - 0.06) / 0.56) ** 2) ** 1.5)
    over(canvas, np.array([125, 28, 5], dtype=np.float32),
         ember_bed * sphere_alpha * 0.38)

    # Flame glow behind the tongues.
    glow_mask = np.zeros((s, s), dtype=np.float32)
    for (bx, tx, w, sw, ph) in (
        (0.00, -0.48, 0.19, 0.085, phase),
        (-0.19, -0.35, 0.10, 0.055, phase + 1.2),
        (0.20, -0.29, 0.09, -0.055, phase + 3.1),
    ):
        m = mask_from_polygon(s, flame_polygon(
            s, 0.03, tx, w, sw, ph, base_x=bx))
        glow_mask = np.maximum(glow_mask, m)
    add_flame(canvas, glow_mask * sphere_alpha, (255, 100, 10),
              (255, 170, 30), 0.38, blur=0.018 * s)

    # Layered tongue silhouettes, clipped to the orb.
    tongues = (
        (-0.21, -0.36, 0.078, 0.055, phase + 1.2, 0),
        (0.22, -0.30, 0.074, -0.055, phase + 3.1, 0),
        (0.00, -0.48, 0.160, 0.085, phase, 1),
    )
    for bx, tx, w, sw, ph, kind in tongues:
        m = mask_from_polygon(s, flame_polygon(
            s, 0.03, tx, w, sw, ph,
            base_x=bx + 0.01 * math.sin(ph)))
        m *= sphere_alpha
        if kind == 0:
            add_flame(canvas, m, (255, 82, 5), (255, 150, 24), 0.96)
        else:
            add_flame(canvas, m, (190, 25, 2), (255, 105, 12), 1.0)

    # Main tongue: dark outline, orange body, yellow inner, white-hot core.
    for (base_y, tx, w, sw, tip_rgb, base_rgb, alpha) in (
        (0.10, -0.48, 0.172, 0.078, (150, 18, 2), (255, 80, 8), 1.0),
        (0.10, -0.46, 0.145, 0.074, (255, 52, 2), (255, 142, 18), 1.0),
        (0.09, -0.34, 0.100, 0.052, (255, 120, 6), (255, 215, 48), 1.0),
        (0.08, -0.18, 0.034, 0.024, (255, 240, 130), (255, 255, 215), 0.96),
    ):
        m = mask_from_polygon(s, flame_polygon(
            s, base_y, tx, w, sw, phase + 0.4))
        m *= sphere_alpha
        add_flame(canvas, m, tip_rgb, base_rgb, alpha)

    # Embers orbiting inside the orb.
    for k in range(3):
        ang = phase * 1.15 + k * 2.15
        sx = 0.27 * math.cos(ang)
        sy = -0.02 + 0.33 * math.sin(ang * 1.25 + k)
        dot = np.exp(-(((x - sx) ** 2 + (y - sy) ** 2) / (0.012 ** 2)))
        dot *= 0.55 + 0.35 * math.sin(phase * 2 + k * 2.0)
        over(canvas, np.array([255, 245, 190], dtype=np.float32),
             dot * sphere_alpha)

    # Specular highlight and bottom-right rim light.
    hl = 1.0 - smoothstep(0.80, 1.0, np.sqrt(
        ((x + 0.23) / 0.34) ** 2 + ((y + 0.27) / 0.22) ** 2))
    hl *= 0.21 * (0.8 + 0.2 * math.sin(phase))
    over(canvas, np.array([255, 252, 230], dtype=np.float32), hl)

    spec = np.exp(-(((x + 0.31) ** 2 + (y + 0.34) ** 2) / (0.035 ** 2)))
    over(canvas, np.array([255, 255, 245], dtype=np.float32), spec * 0.75)

    arc_r = r0 - 0.023
    arc = np.exp(-((r - arc_r) / 0.018) ** 2)
    arc *= (x > 0.05) & (y > -0.02) & (r < r0 + 0.01)
    over(canvas, np.array([255, 225, 130], dtype=np.float32), arc * 0.55)

    out_arr = np.clip(canvas, 0, 255)
    out_arr[..., 3] = np.clip(canvas[..., 3], 0.0, 1.0) * 255.0
    out = Image.fromarray(out_arr.astype(np.uint8), "RGBA")
    return out.resize((size, size), Image.LANCZOS)


def main():
    for name, size in (("normal", 98), ("small", 76)):
        folder = OUT / name
        folder.mkdir(parents=True, exist_ok=True)
        for i in range(FRAMES):
            render(size, i).save(folder / f"{i}.png")
            print(f"wrote {folder / f'{i}.png'}")


if __name__ == "__main__":
    main()
