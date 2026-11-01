#!/usr/bin/env python3
"""Generate source art for the ice_ball_cup card.

Outputs PNG source frames under art/ice_ball_cup*/; package them afterwards
with tools/build_sprite_resource.py.
"""

from __future__ import annotations

import math
import os
import shutil

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ART = os.path.join(ROOT, "art")
K = 4

PORCELAIN = (244, 239, 228, 255)
PORCELAIN_SH = (213, 205, 190, 255)
PORCELAIN_HI = (255, 255, 255, 230)
GOLD = (216, 168, 74, 255)
GOLD_HI = (255, 226, 140, 255)
DEEP = (27, 58, 70, 255)
CYAN = (88, 224, 255, 255)
CYAN_SOFT = (150, 240, 255, 255)
MAGENTA = (210, 77, 255, 255)
WHITE = (255, 255, 255, 255)


def s(v: float) -> int:
    return int(round(v * K))


def canvas(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w * K, h * K), (0, 0, 0, 0))


def finish(img: Image.Image, w: int, h: int) -> Image.Image:
    return img.resize((w, h), Image.LANCZOS)


def outline(draw: ImageDraw.ImageDraw, pts, color=DEEP, width=2.0):
    p = [(s(x), s(y)) for x, y in pts]
    draw.line(p + [p[0]], fill=color, width=s(width), joint="curve")


def ellipse(draw, box, fill=None, outline_col=None, width=2.0):
    box = [s(box[0]), s(box[1]), s(box[2]), s(box[3])]
    draw.ellipse(box, fill=fill, outline=outline_col, width=s(width))


def glow_ring(img: Image.Image, cx, cy, rx, ry, color, width=2.0, layers=6):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(layers, 0, -1):
        a = int(18 + (layers - i) * 10)
        ellipse(d, (cx - rx - i, cy - ry - i * 0.5, cx + rx + i, cy + ry + i * 0.5),
                outline_col=(color[0], color[1], color[2], a), width=width + i * 0.5)
    return Image.alpha_composite(img, layer.filter(ImageFilter.GaussianBlur(s(1.2))))


def radial_ball(img: Image.Image, cx, cy, r, inner=(255, 255, 255, 255),
                outer=CYAN, edge=MAGENTA):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(36, 0, -1):
        t = i / 36.0
        col = (
            int(inner[0] * (1 - t) + outer[0] * t),
            int(inner[1] * (1 - t) + outer[1] * t),
            int(inner[2] * (1 - t) + outer[2] * t),
            255,
        )
        rr = r * t
        d.ellipse([s(cx - rr), s(cy - rr), s(cx + rr), s(cy + rr)], fill=col)
    # rim
    d.ellipse([s(cx - r), s(cy - r), s(cx + r), s(cy + r)], outline=DEEP, width=s(2))
    d.ellipse([s(cx - r + 1), s(cy - r + 1), s(cx + r - 1), s(cy + r - 1)],
              outline=(edge[0], edge[1], edge[2], 120), width=s(1.2))
    return Image.alpha_composite(img, layer)


def body(shape: int) -> Image.Image:
    w, h = 96, 144
    img = canvas(w, h)
    d = ImageDraw.Draw(img)

    # shadow
    ellipse(d, (14, 128, 82, 142), fill=(0, 0, 0, 45))

    # saucer
    ellipse(d, (8, 124, 88, 141), fill=PORCELAIN, outline_col=DEEP, width=2.2)
    ellipse(d, (16, 128, 80, 138), fill=PORCELAIN_SH, outline_col=None)
    img = glow_ring(img, 48, 133, 31, 5, MAGENTA, width=1.5)
    d = ImageDraw.Draw(img)

    # stem
    d.polygon([(s(42), s(96)), (s(54), s(96)), (s(50), s(128)), (s(46), s(128))],
              fill=(228, 246, 252, 255), outline=DEEP)
    d.line([(s(45), s(100)), (s(45), s(124))], fill=(255, 255, 255, 170), width=s(1.2))
    d.rectangle([s(41), s(101), s(55), s(106)], fill=GOLD, outline=DEEP)
    d.rectangle([s(43), s(119), s(53), s(124)], fill=GOLD, outline=DEEP)
    d.line([(s(42), s(102)), (s(54), s(102))], fill=GOLD_HI, width=s(1))

    if shape < 2:
        # goblet bowl
        pts = [(24, 54), (72, 54), (64, 96), (56, 101), (40, 101), (32, 96)]
        d.polygon([(s(x), s(y)) for x, y in pts], fill=(226, 247, 253, 255), outline=DEEP)
        # inner chamber
        inner = [(31, 60), (65, 60), (59, 92), (54, 96), (42, 96), (37, 92)]
        d.polygon([(s(x), s(y)) for x, y in inner], fill=(22, 55, 70, 255))
        # cyan liquid
        ellipse(d, (36, 78, 60, 94), fill=(88, 224, 255, 120), outline_col=None)
        ellipse(d, (40, 82, 56, 92), fill=(180, 248, 255, 140), outline_col=None)
        # rim
        ellipse(d, (23, 52, 73, 62), outline_col=GOLD, width=3.0)
        d.arc([s(23), s(52), s(73), s(62)], 185, 355, fill=(255, 255, 255, 210), width=s(1.2))
        # glass highlight
        d.arc([s(29), s(62), s(43), s(97)], 95, 200, fill=(255, 255, 255, 150), width=s(2.0))
        d.line([(s(35), s(66)), (s(40), s(88))], fill=(255, 255, 255, 120), width=s(1.2))
    else:
        # blooming 4-petal cup
        outer = [
            [(48, 100), (33, 94), (20, 80), (13, 62), (16, 47), (27, 41), (38, 50), (45, 72)],
            [(48, 100), (63, 94), (76, 80), (83, 62), (80, 47), (69, 41), (58, 50), (51, 72)],
        ]
        inner = [
            [(48, 100), (38, 90), (31, 74), (32, 58), (39, 49), (47, 64)],
            [(48, 100), (58, 90), (65, 74), (64, 58), (57, 49), (49, 64)],
        ]
        for pts in outer:
            d.polygon([(s(x), s(y)) for x, y in pts], fill=(242, 237, 226, 255), outline=DEEP)
            d.line([(s(pts[0][0]), s(pts[0][1])), (s(pts[-1][0]), s(pts[-1][1]))],
                   fill=GOLD, width=s(1.2))
        for pts in inner:
            d.polygon([(s(x), s(y)) for x, y in pts], fill=(226, 246, 252, 255), outline=DEEP)
            d.line([(s(pts[0][0]), s(pts[0][1])), (s(pts[-1][0]), s(pts[-1][1]))],
                   fill=GOLD, width=s(1.2))
        for pts in outer + inner:
            mid = pts[len(pts) // 2]
            d.line([(s(pts[0][0]), s(pts[0][1])), (s(mid[0]), s(mid[1]))],
                   fill=(255, 255, 255, 110), width=s(1.0))
        # inner chamber
        ellipse(d, (31, 64, 65, 99), fill=(22, 55, 70, 255), outline_col=DEEP, width=2.0)
        ellipse(d, (37, 80, 59, 96), fill=(88, 224, 255, 120), outline_col=None)
        # gold filigree
        ellipse(d, (22, 54, 74, 70), outline_col=GOLD, width=2.0)
        for a in (20, 160, 200, 340):
            r = math.radians(a)
            d.line([(s(48), s(76)), (s(48 + 24 * math.cos(r)), s(76 + 15 * math.sin(r)))],
                   fill=GOLD, width=s(1.4))
        img = glow_ring(img, 48, 80, 22, 12, MAGENTA, width=1.2, layers=4)
        d = ImageDraw.Draw(img)

    # final outline pass on the cup silhouette
    if shape < 2:
        p = [(24, 54), (72, 54), (64, 96), (56, 101), (40, 101), (32, 96)]
        outline(d, p, DEEP, 2.0)
    else:
        pass

    # small gold emblem on stem
    ellipse(d, (45, 108, 51, 114), fill=GOLD, outline_col=DEEP, width=1.0)
    return finish(img, w, h)


def arm() -> Image.Image:
    w, h = 20, 78
    img = canvas(w, h)
    d = ImageDraw.Draw(img)
    pts = [(10, 76), (7, 62), (5, 48), (7, 34), (10, 21), (13, 10), (16, 5), (18, 8), (16, 18), (13, 30), (12, 44), (12, 58), (13, 76)]
    d.polygon([(s(x), s(y)) for x, y in pts], fill=(92, 208, 240, 255), outline=DEEP)
    # glass highlight / shadow
    d.line([(s(9), s(72)), (s(8), s(50)), (s(10), s(28)), (s(14), s(12))],
           fill=(220, 252, 255, 210), width=s(1.6))
    d.line([(s(13), s(72)), (s(12), s(48)), (s(14), s(24)), (s(17), s(10))],
           fill=(20, 120, 155, 150), width=s(1.2))
    # thin gold base ring, no ball (avoids the bead row)
    d.line([(s(5), s(74)), (s(15), s(74))], fill=GOLD, width=s(1.2))
    # tip glow
    img = glow_ring(img, 17, 7, 4, 4, CYAN, width=1.0, layers=3)
    d = ImageDraw.Draw(img)
    ellipse(d, (15, 5, 19, 9), fill=WHITE, outline_col=None)
    return finish(img, w, h)


def orb(shape: int) -> Image.Image:
    w, h = 64, 64
    img = canvas(w, h)
    img = radial_ball(img, 32, 32, 23, inner=(255, 255, 255, 255),
                      outer=CYAN, edge=MAGENTA if shape >= 1 else CYAN)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    # prism facets
    facets = [
        [(32, 12), (22, 30), (32, 50)],
        [(32, 12), (44, 30), (32, 50)],
        [(20, 38), (32, 50), (44, 38)],
    ]
    for i, pts in enumerate(facets):
        col = (255, 255, 255, 55) if i % 2 == 0 else (210, 77, 255, 45)
        d.polygon([(s(x), s(y)) for x, y in pts], fill=col)
    d.line([(s(23), s(24)), (s(32), s(14)), (s(41), s(24))], fill=(255, 255, 255, 140), width=s(1.2))
    # specular
    d.ellipse([s(21), s(18), s(28), s(25)], fill=(255, 255, 255, 220))
    img = Image.alpha_composite(img, layer)
    return finish(img, w, h)


def ring() -> Image.Image:
    w, h = 120, 48
    img = canvas(w, h)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(9, 0, -1):
        a = int(14 + (9 - i) * 10)
        ellipse(d, (60 - 50 - i, 24 - 16 - i * 0.5, 60 + 50 + i, 24 + 16 + i * 0.5),
                outline_col=(88, 224, 255, a), width=1.4 + i * 0.4)
    ellipse(d, (10, 8, 110, 40), outline_col=(200, 250, 255, 220), width=1.2)
    ellipse(d, (18, 12, 102, 36), outline_col=(255, 255, 255, 120), width=0.8)
    img = Image.alpha_composite(img, layer)
    return finish(img, w, h)


def impact_frame(frame: int) -> Image.Image:
    w, h = 64, 64
    img = canvas(w, h)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    p = frame / 5.0
    fade = 1.0 - p
    # central flash
    r = 5 + 12 * fade
    d.ellipse([s(32 - r), s(32 - r), s(32 + r), s(32 + r)],
              fill=(255, 255, 255, int(220 * fade)))
    # expanding ring
    rr = 8 + 24 * p
    d.ellipse([s(32 - rr), s(32 - rr * 0.8), s(32 + rr), s(32 + rr * 0.8)],
              outline=(88, 224, 255, int(220 * fade)), width=s(2.2))
    d.ellipse([s(32 - rr * 0.75), s(32 - rr * 0.6), s(32 + rr * 0.75), s(32 + rr * 0.6)],
              outline=(210, 77, 255, int(180 * fade)), width=s(1.4))
    # spokes
    for i in range(8):
        a = math.radians(i * 45 + p * 20)
        r0 = 4 + 8 * p
        r1 = 14 + 20 * p
        d.line([(s(32 + r0 * math.cos(a)), s(32 + r0 * math.sin(a))),
                (s(32 + r1 * math.cos(a)), s(32 + r1 * math.sin(a)))],
               fill=(200, 250, 255, int(200 * fade)), width=s(1.4))
    # sparks
    for i in range(6):
        a = math.radians(i * 60 + 15)
        rr2 = 18 + 14 * p
        px = 32 + rr2 * math.cos(a)
        py = 32 + rr2 * math.sin(a)
        d.ellipse([s(px - 2), s(py - 2), s(px + 2), s(py + 2)],
                  fill=(255, 255, 255, int(200 * fade)))
    img = Image.alpha_composite(img, layer.filter(ImageFilter.GaussianBlur(s(0.6))))
    return finish(img, w, h)


def aa_lens() -> Image.Image:
    w, h = 28, 28
    img = canvas(w, h)
    img = glow_ring(img, 14, 14, 8, 8, MAGENTA, width=1.0, layers=4)
    d = ImageDraw.Draw(img)
    d.polygon([(s(14), s(4)), (s(24), s(14)), (s(14), s(24)), (s(4), s(14))],
              fill=(230, 250, 255, 230), outline=DEEP)
    d.polygon([(s(14), s(8)), (s(20), s(14)), (s(14), s(20)), (s(8), s(14))],
              fill=(88, 224, 255, 230), outline=None)
    ellipse(d, (12, 12, 16, 16), fill=WHITE, outline_col=None)
    return finish(img, w, h)


def icon(shape: int) -> Image.Image:
    w, h = 91, 120
    img = Image.new("RGBA", (w * K, h * K), (0, 0, 0, 0))

    glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for i in range(10, 0, -1):
        rx = 28 + i * 2
        ry = 8 + i
        gd.ellipse([s(45 - rx), s(104 - ry), s(45 + rx), s(104 + ry)], fill=(210, 77, 255, 7))
    for i in range(8, 0, -1):
        rr = 16 + i * 2
        gd.ellipse([s(45 - rr), s(46 - rr), s(45 + rr), s(46 + rr)], fill=(88, 224, 255, 7))
    img = Image.alpha_composite(img, glow.filter(ImageFilter.GaussianBlur(s(3))))

    gd = ImageDraw.Draw(img)
    gd.ellipse([s(45 - 26), s(104 - 7), s(45 + 26), s(104 + 7)], fill=(88, 224, 255, 38))
    gd.ellipse([s(45 - 18), s(104 - 5), s(45 + 18), s(104 + 5)], fill=(210, 77, 255, 42))
    for i in range(4):
        gd.ellipse([s(45 - 30 + i * 2), s(104 - 9 + i), s(45 + 30 - i * 2), s(104 + 9 - i)],
                   outline=(88, 224, 255, 90 - i * 15), width=s(1.2))
    gd.polygon([(s(45 - 10), s(104)), (s(45 + 10), s(104)), (s(45), s(58))],
               fill=(88, 224, 255, 18))
    for i in range(6):
        u = (i * 0.17) % 1.0
        mx = 45 + math.sin(i * 2.1) * 10
        my = 104 - u * 50
        gd.ellipse([s(mx - 1), s(my - 1), s(mx + 1), s(my + 1)], fill=(200, 250, 255, 130))

    orb_size = 32 if shape < 2 else 36
    o = orb(shape).resize((orb_size * K, orb_size * K), Image.LANCZOS)
    img.alpha_composite(o, (int((45 - orb_size / 2) * K), int((46 - orb_size / 2) * K)))

    r = ring().resize((70 * K, 28 * K), Image.LANCZOS)
    ring_count = 2 + shape
    angles = [18, -28, 70, -62]
    alphas = [90, 75, 60, 50]
    for i in range(ring_count):
        rr = r.rotate(angles[i], resample=Image.BICUBIC, expand=True)
        rr.putalpha(rr.getchannel("A").point(lambda v: v * alphas[i] // 255))
        img.alpha_composite(rr, (int((45 - rr.width / (2 * K)) * K),
                                 int((46 - rr.height / (2 * K)) * K)))

    if shape >= 1:
        l = aa_lens().resize((14 * K, 14 * K), Image.LANCZOS)
        img.alpha_composite(l, (int((56 - 7) * K), int((20 - 7) * K)))
    return finish(img, w, h)


def beam_quad() -> Image.Image:
    return Image.new("RGBA", (2, 2), (255, 255, 255, 255))


def save(path: str, img: Image.Image):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)


def main():
    os.makedirs(ART, exist_ok=True)
    save(os.path.join(ART, "ice_ball_cup_orb", "0.png"), orb(0))
    save(os.path.join(ART, "ice_ball_cup_orb_1", "0.png"), orb(1))
    save(os.path.join(ART, "ice_ball_cup_orb_2", "0.png"), orb(2))
    save(os.path.join(ART, "ice_ball_cup_ring", "0.png"), ring())
    save(os.path.join(ART, "ice_ball_cup_aa_lens", "0.png"), aa_lens())
    save(os.path.join(ART, "ice_ball_cup_icon", "0.png"), icon(0))
    save(os.path.join(ART, "ice_ball_cup_icon_1", "0.png"), icon(1))
    save(os.path.join(ART, "ice_ball_cup_icon_2", "0.png"), icon(2))
    save(os.path.join(ART, "ice_beam_quad", "0.png"), beam_quad())
    print("generated art under", ART)


if __name__ == "__main__":
    main()
