#!/usr/bin/env python3
"""Generate the layered coffee-pot turret source art as SVG.

The SVGs are development sources only; the game uses the rendered PNG layers.
Run this, render each SVG at 2x with Chrome, then package the downscaled PNGs
with tools/build_sprite_resource.py.
"""

from __future__ import annotations

import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "art", "coffee_pot", "svg")

COLORS = {
    0: {
        "ceramic": "#4a2c63",
        "ceramic_hi": "#8159a4",
        "ceramic_lo": "#1b0d28",
        "metal": "#6d4a2b",
        "brass": "#c9954f",
        "brass_hi": "#ffe2a3",
        "copper": "#9e5638",
        "glass": "#9dc4d2",
        "liquid": "#c97424",
        "liquid_hi": "#ffd27e",
        "plate": "#100a17",
        "eye": "#ffd47a",
        "glow": "#ffb15a",
    },
    1: {
        "ceramic": "#3d2559",
        "ceramic_hi": "#7d55a6",
        "ceramic_lo": "#150a22",
        "metal": "#7d552e",
        "brass": "#e0b46b",
        "brass_hi": "#fff0bd",
        "copper": "#b86a42",
        "glass": "#a9d0dc",
        "liquid": "#b9651d",
        "liquid_hi": "#ffd995",
        "plate": "#0d0914",
        "eye": "#ffe09a",
        "glow": "#ffc06a",
    },
    2: {
        "ceramic": "#5a1b26",
        "ceramic_hi": "#b54842",
        "ceramic_lo": "#21070b",
        "metal": "#6d2f1f",
        "brass": "#d18a4c",
        "brass_hi": "#ffd39a",
        "copper": "#d06b3d",
        "glass": "#e3a28b",
        "liquid": "#e84016",
        "liquid_hi": "#ffd36a",
        "plate": "#180609",
        "eye": "#ff5a2e",
        "glow": "#ff6424",
    },
}


def defs(c: dict) -> str:
    return f"""
  <defs>
    <linearGradient id="ceramic" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{c['ceramic_hi']}"/>
      <stop offset="0.28" stop-color="{c['ceramic']}"/>
      <stop offset="1" stop-color="{c['ceramic_lo']}"/>
    </linearGradient>
    <linearGradient id="metal" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="{c['metal']}"/>
      <stop offset="0.45" stop-color="{c['brass']}"/>
      <stop offset="1" stop-color="{c['metal']}"/>
    </linearGradient>
    <linearGradient id="brass" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{c['brass_hi']}"/>
      <stop offset="0.35" stop-color="{c['brass']}"/>
      <stop offset="1" stop-color="{c['copper']}"/>
    </linearGradient>
    <linearGradient id="glass" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#ffffff" stop-opacity="0.38"/>
      <stop offset="0.45" stop-color="{c['glass']}" stop-opacity="0.16"/>
      <stop offset="1" stop-color="#ffffff" stop-opacity="0.26"/>
    </linearGradient>
    <linearGradient id="amber" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{c['liquid_hi']}"/>
      <stop offset="0.22" stop-color="{c['liquid']}"/>
      <stop offset="1" stop-color="#371208"/>
    </linearGradient>
    <filter id="glow" x="-60%" y="-60%" width="220%" height="220%">
      <feGaussianBlur stdDeviation="3.2" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>"""


def svg(content: str, c: dict) -> str:
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="306" height="360" viewBox="0 0 153 180">
{defs(c)}
{content}
</svg>
"""


def body(shape: int) -> str:
    c = COLORS[shape]
    ornament = ""
    if shape == 1:
        ornament = f"""
      <path d="M 43 64 C 32 68 28 80 34 92 C 26 94 24 106 32 113"
            fill="none" stroke="url(#brass)" stroke-width="4" stroke-linecap="round"/>
      <path d="M 109 64 C 120 69 124 81 118 93"
            fill="none" stroke="url(#brass)" stroke-width="4" stroke-linecap="round"/>
      <path d="M 42 108 C 55 116 98 116 110 106"
            fill="none" stroke="url(#brass)" stroke-width="5" stroke-linecap="round"/>
      <path d="M 43 112 C 56 120 97 120 109 110"
            fill="none" stroke="#6d4a2b" stroke-width="1.6" opacity="0.85"/>
      <path d="M 22 94 C 15 100 15 122 24 129 L 35 124 L 35 98 Z"
            fill="url(#metal)" stroke="#07040b" stroke-width="2.5"/>
      <path d="M 24 100 L 31 100 L 31 121 L 24 121 Z" fill="{c['ceramic_hi']}" opacity="0.55"/>
      <circle cx="76" cy="112" r="3" fill="{c['brass_hi']}" stroke="#5c371d" stroke-width="1"/>
      <circle cx="54" cy="112" r="2.4" fill="{c['brass_hi']}" stroke="#5c371d" stroke-width="1"/>
      <circle cx="98" cy="112" r="2.4" fill="{c['brass_hi']}" stroke="#5c371d" stroke-width="1"/>
      <path d="M 38 146 L 47 136 L 106 136 L 114 146" fill="none"
            stroke="url(#brass)" stroke-width="4" stroke-linecap="round"/>
    """
    elif shape == 2:
        ornament = f"""
      <path d="M 42 64 C 30 68 26 80 33 92 C 24 95 22 108 31 116"
            fill="none" stroke="url(#brass)" stroke-width="4" stroke-linecap="round"/>
      <path d="M 108 64 C 120 69 124 81 118 93"
            fill="none" stroke="url(#brass)" stroke-width="4" stroke-linecap="round"/>
      <path d="M 20 92 C 12 102 12 124 24 133"
            fill="none" stroke="{c['copper']}" stroke-width="5" stroke-linecap="round"/>
      <path d="M 25 98 C 18 108 18 120 28 128"
            fill="none" stroke="{c['brass']}" stroke-width="2.4" stroke-linecap="round"/>

      <circle cx="43" cy="113" r="13" fill="#d7d3c5" stroke="#07040b" stroke-width="2.8"/>
      <circle cx="43" cy="113" r="9" fill="none" stroke="{c['brass']}" stroke-width="2"/>
      <path d="M 43 113 L 49 106" stroke="#12080a" stroke-width="2.4" stroke-linecap="round"/>
      <path d="M 43 102 L 43 104 M 54 113 L 52 113 M 43 124 L 43 122 M 32 113 L 34 113"
            stroke="#6b5b4d" stroke-width="1.6" stroke-linecap="round"/>
      <circle cx="43" cy="113" r="2.6" fill="{c['glow']}"/>

      <path d="M 54 148 L 66 138 L 96 138 L 106 148" fill="none"
            stroke="{c['copper']}" stroke-width="4" stroke-linecap="round"/>
      <path d="M 61 154 L 70 148 L 92 148 L 101 154" fill="none"
            stroke="#6d2f1f" stroke-width="3" stroke-linecap="round"/>
      <circle cx="66" cy="164" r="3.4" fill="{c['glow']}" filter="url(#glow)"/>
      <circle cx="82" cy="166" r="2.6" fill="{c['glow']}" filter="url(#glow)"/>
      <circle cx="96" cy="163" r="2" fill="{c['glow']}" filter="url(#glow)"/>
      <path d="M 51 92 L 57 92 L 57 104 L 51 104 Z" fill="{c['glow']}" opacity="0.65" filter="url(#glow)"/>
      <path d="M 99 108 L 105 108 L 105 120 L 99 120 Z" fill="{c['glow']}" opacity="0.55" filter="url(#glow)"/>
    """

    return svg(f"""
  <g>
    <path d="M 21 80 C 10 91 10 126 27 140 L 43 132 L 42 92 Z"
          fill="{c['metal']}" stroke="#07040b" stroke-width="3"/>
    <path d="M 26 88 C 18 97 18 120 31 133 L 37 129 L 37 93 Z"
          fill="{c['ceramic']}" opacity="0.78"/>

    <path d="M 76 49
             L 100 54 L 110 68 L 114 88
             L 106 96 L 108 136 L 117 145
             L 112 158 L 76 172 L 40 158
             L 35 145 L 44 136 L 46 96
             L 38 88 L 42 68 L 52 54 Z
             M 50 80 L 100 80 L 100 134 L 94 141 L 56 141 L 50 134 Z"
          fill="url(#ceramic)" fill-rule="evenodd" stroke="#07040b" stroke-width="3.2" stroke-linejoin="round"/>

    <path d="M 50 80 L 100 80 L 100 134 L 94 141 L 56 141 L 50 134 Z"
          fill="url(#glass)"/>
    <path d="M 50 80 L 100 80 L 100 134 L 94 141 L 56 141 L 50 134 Z"
          fill="none" stroke="url(#brass)" stroke-width="4" stroke-linejoin="round"/>
    <path d="M 53 84 L 97 84 L 97 132 L 92 138 L 58 138 L 53 132 Z"
          fill="none" stroke="{c['brass_hi']}" stroke-width="1.2" opacity="0.45"/>
    <path d="M 55 87 L 64 87 L 51 136 L 47 136 Z" fill="#ffffff" opacity="0.20"/>
    <path d="M 91 87 L 97 87 L 95 132 L 89 132 Z" fill="#ffffff" opacity="0.10"/>

    <path d="M 51 59 C 59 55 93 55 101 59" fill="none" stroke="{c['brass_hi']}" stroke-width="2" opacity="0.5" stroke-linecap="round"/>
    <path d="M 42 68 C 52 62 100 62 110 68" fill="none" stroke="{c['ceramic_hi']}" stroke-width="3" opacity="0.55" stroke-linecap="round"/>

    <path d="M 39 76 C 12 68 7 121 38 139" fill="none" stroke="#07040b" stroke-width="17" stroke-linecap="round"/>
    <path d="M 39 76 C 12 68 7 121 38 139" fill="none" stroke="url(#metal)" stroke-width="11" stroke-linecap="round"/>
    <path d="M 18 86 C 12 96 12 117 21 128" fill="none" stroke="{c['brass_hi']}" stroke-width="2" opacity="0.55" stroke-linecap="round"/>
    <path d="M 27 84 L 34 86 M 16 98 L 23 100 M 16 116 L 23 118 M 27 132 L 34 130"
          stroke="{c['copper']}" stroke-width="3" stroke-linecap="round"/>

    <path d="M 104 88 L 130 90 L 130 95 L 146 97 L 146 111 L 130 113 L 130 118 L 104 120 Z"
          fill="url(#metal)" stroke="#07040b" stroke-width="3" stroke-linejoin="round"/>
    <path d="M 108 92 L 128 93 L 128 97 L 141 98 L 141 110 L 128 111 L 128 115 L 108 116 Z"
          fill="{c['ceramic']}" opacity="0.65"/>
    <path d="M 112 91 L 118 91 L 118 117 L 112 117 Z" fill="url(#brass)" stroke="#07040b" stroke-width="2"/>
    <path d="M 122 92 L 127 92 L 127 116 L 122 116 Z" fill="url(#brass)" stroke="#07040b" stroke-width="2"/>
    <path d="M 133 97 L 146 97 L 146 111 L 133 111 Z" fill="#12070b" stroke="#07040b" stroke-width="2"/>
    <ellipse cx="146" cy="104" rx="2.6" ry="7" fill="#050208"/>
    <path d="M 135 98 L 142 98 M 135 110 L 142 110" stroke="{c['brass_hi']}" stroke-width="1.4" opacity="0.7"/>
    <path d="M 134 96 L 134 100 M 137 96 L 137 100" stroke="{c['glow']}" stroke-width="1.6" opacity="0.8"/>

    <path d="M 72 62 L 106 67 L 107 79 L 96 86 L 72 82 Z"
          fill="{c['plate']}" stroke="#07040b" stroke-width="2.8" stroke-linejoin="round"/>
    <path d="M 74 65 L 103 69 L 104 77 L 95 82 L 74 79 Z"
          fill="none" stroke="{c['brass']}" stroke-width="1.8" opacity="0.75"/>
    <path d="M 75 78 L 94 83" stroke="{c['ceramic_hi']}" stroke-width="1.6" opacity="0.5" stroke-linecap="round"/>

    <path d="M 44 60 C 56 56 96 56 108 61" fill="none" stroke="#07040b" stroke-width="2.4" opacity="0.55"/>
    <path d="M 50 145 L 102 145" stroke="{c['brass_hi']}" stroke-width="1.5" opacity="0.25"/>

    {ornament}
  </g>""", c)


def base(shape: int) -> str:
    c = COLORS[shape]
    ornament = ""
    if shape == 1:
        ornament = f"""
      <path d="M 30 153 C 51 160 101 160 122 153" fill="none" stroke="url(#brass)" stroke-width="4" stroke-linecap="round"/>
      <path d="M 34 160 C 53 166 99 166 118 160" fill="none" stroke="{c['brass_hi']}" stroke-width="1.5" opacity="0.55"/>
      <circle cx="44" cy="160" r="2.4" fill="{c['brass_hi']}"/>
      <circle cx="108" cy="160" r="2.4" fill="{c['brass_hi']}"/>
    """
    elif shape == 2:
        ornament = f"""
      <path d="M 30 153 C 51 160 101 160 122 153" fill="none" stroke="{c['copper']}" stroke-width="4" stroke-linecap="round"/>
      <path d="M 36 161 C 54 167 98 167 116 161" fill="none" stroke="{c['glow']}" stroke-width="2" opacity="0.65" filter="url(#glow)"/>
      <circle cx="44" cy="160" r="2.8" fill="{c['glow']}" filter="url(#glow)"/>
      <circle cx="108" cy="160" r="2.4" fill="{c['glow']}" filter="url(#glow)"/>
      <path d="M 58 165 L 94 165" stroke="{c['brass']}" stroke-width="2" opacity="0.5"/>
    """

    return svg(f"""
  <g>
    <ellipse cx="76" cy="168" rx="58" ry="12" fill="#050208" opacity="0.62"/>
    <ellipse cx="76" cy="162" rx="53" ry="12" fill="#1a0c22" stroke="#07040b" stroke-width="3"/>
    <path d="M 25 153 L 35 144 L 117 144 L 127 153 L 121 168 L 31 168 Z"
          fill="url(#metal)" stroke="#07040b" stroke-width="3" stroke-linejoin="round"/>
    <path d="M 32 155 L 40 151 L 112 151 L 120 155" fill="none"
          stroke="{c['brass_hi']}" stroke-width="2" opacity="0.45"/>
    <path d="M 27 160 L 34 157 L 34 166 L 29 168 Z" fill="{c['brass']}" stroke="#07040b" stroke-width="1.6"/>
    <path d="M 125 160 L 118 157 L 118 166 L 123 168 Z" fill="{c['brass']}" stroke="#07040b" stroke-width="1.6"/>
    {ornament}
  </g>""", c)


def lid(shape: int) -> str:
    c = COLORS[shape]
    ornament = ""
    if shape == 1:
        ornament = f"""
      <path d="M 52 40 C 61 31 91 31 100 40" fill="none" stroke="url(#brass)" stroke-width="5" stroke-linecap="round"/>
      <circle cx="76" cy="22" r="5.5" fill="url(#brass)" stroke="#07040b" stroke-width="2"/>
      <path d="M 55 50 C 64 45 88 45 97 50" fill="none" stroke="{c['brass_hi']}" stroke-width="2" opacity="0.7"/>
      <path d="M 61 33 L 56 27 L 66 31 M 91 33 L 96 27 L 86 31" fill="none" stroke="url(#brass)" stroke-width="3" stroke-linecap="round"/>
    """
    elif shape == 2:
        ornament = f"""
      <rect x="94" y="11" width="8" height="32" rx="4" fill="url(#metal)" stroke="#07040b" stroke-width="2.2"/>
      <rect x="90" y="7" width="16" height="7" rx="3.5" fill="url(#brass)" stroke="#07040b" stroke-width="1.8"/>
      <path d="M 98 7 C 94 1 101 -2 99 -8" fill="none" stroke="{c['brass']}" stroke-width="2.6" stroke-linecap="round"/>
      <path d="M 52 40 C 61 31 91 31 100 40" fill="none" stroke="url(#brass)" stroke-width="4" stroke-linecap="round"/>
      <circle cx="76" cy="22" r="5" fill="{c['glow']}" filter="url(#glow)"/>
      <path d="M 57 48 C 65 44 87 44 95 48" fill="none" stroke="{c['glow']}" stroke-width="2" opacity="0.65" filter="url(#glow)"/>
    """

    return svg(f"""
  <g>
    <ellipse cx="76" cy="54" rx="27" ry="5.5" fill="#07040b" opacity="0.55"/>
    <path d="M 51 54 C 51 42 61 35 76 35 C 91 35 101 42 101 54 Z"
          fill="url(#ceramic)" stroke="#07040b" stroke-width="3.2" stroke-linejoin="round"/>
    <rect x="49" y="49" width="54" height="10" rx="5" fill="url(#metal)" stroke="#07040b" stroke-width="2.8"/>
    <path d="M 53 51 C 63 47 89 47 99 51" fill="none" stroke="{c['brass_hi']}" stroke-width="1.8" opacity="0.55"/>
    <rect x="70" y="27" width="12" height="11" fill="url(#metal)" stroke="#07040b" stroke-width="2.5"/>
    <ellipse cx="76" cy="23" rx="12" ry="7.5" fill="url(#ceramic)" stroke="#07040b" stroke-width="2.8"/>
    <path d="M 59 43 C 67 38 85 38 93 43" fill="none" stroke="#ffffff" stroke-width="2" opacity="0.30" stroke-linecap="round"/>
    {ornament}
  </g>""", c)


def face(kind: int) -> str:
    c = COLORS[0]
    if kind == 0:
        content = f"""
      <path d="M 86 66 C 92 62 100 64 103 70 C 100 75 93 77 87 73 Z"
            fill="#f4e7c8" stroke="#07040b" stroke-width="2"/>
      <circle cx="97" cy="69" r="3.3" fill="{c['eye']}" stroke="#3a1b08" stroke-width="1.3"/>
      <circle cx="98" cy="68" r="1.2" fill="#fff6d8"/>
      <path d="M 84 62 C 90 58 99 59 104 64" fill="none" stroke="#07040b" stroke-width="3" stroke-linecap="round"/>
      <path d="M 94 79 C 99 80 103 78 106 75" fill="none" stroke="#07040b" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M 91 82 L 101 84" stroke="{c['brass']}" stroke-width="1.6" opacity="0.7" stroke-linecap="round"/>
    """
    elif kind == 1:
        content = f"""
      <path d="M 85 67 C 92 63 101 65 104 71 C 100 74 93 76 87 72 Z"
            fill="#f4e7c8" stroke="#07040b" stroke-width="2"/>
      <circle cx="98" cy="69" r="3.1" fill="{c['eye']}" stroke="#3a1b08" stroke-width="1.3"/>
      <circle cx="99" cy="68" r="1.1" fill="#fff6d8"/>
      <path d="M 83 63 C 92 59 100 61 105 65" fill="none" stroke="#07040b" stroke-width="3" stroke-linecap="round"/>
      <path d="M 92 78 C 100 82 104 79 107 75" fill="none" stroke="#07040b" stroke-width="2.7" stroke-linecap="round"/>
      <path d="M 105 73 C 109 73 110 70 108 68" fill="none" stroke="#07040b" stroke-width="2" stroke-linecap="round"/>
    """
    elif kind == 2:
        content = f"""
      <path d="M 85 66 C 92 62 101 64 104 70 C 100 74 93 76 87 72 Z"
            fill="#f0d6b1" stroke="#07040b" stroke-width="2"/>
      <circle cx="98" cy="69" r="3.1" fill="{c['eye']}" stroke="#3a1008" stroke-width="1.4"/>
      <circle cx="99" cy="68" r="1.1" fill="#fff2c8"/>
      <path d="M 82 60 L 96 65" fill="none" stroke="#07040b" stroke-width="3.4" stroke-linecap="round"/>
      <path d="M 106 59 L 100 65" fill="none" stroke="#07040b" stroke-width="3.4" stroke-linecap="round"/>
      <path d="M 90 79 L 102 77" fill="none" stroke="#07040b" stroke-width="2.8" stroke-linecap="round"/>
      <path d="M 94 82 L 100 84" stroke="{c['brass']}" stroke-width="1.6" opacity="0.65" stroke-linecap="round"/>
    """
    else:
        content = f"""
      <path d="M 86 69 C 93 66 100 67 104 71 C 100 74 93 75 87 72 Z"
            fill="#d8cbb2" stroke="#07040b" stroke-width="2"/>
      <path d="M 87 70 C 93 68 100 69 103 71" fill="none" stroke="#07040b" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M 84 62 C 90 60 98 60 104 64" fill="none" stroke="#07040b" stroke-width="2.6" stroke-linecap="round" opacity="0.7"/>
      <path d="M 96 80 C 99 81 102 80 104 79" fill="none" stroke="#07040b" stroke-width="2.2" stroke-linecap="round"/>
      <path d="M 104 64 C 107 61 109 62 110 65" fill="none" stroke="{c['brass']}" stroke-width="1.5" opacity="0.5" stroke-linecap="round"/>
    """
    return svg(f"<g>{content}</g>", c)


def liquid(shape: int) -> str:
    c = COLORS[shape]
    glow = ""
    if shape == 2:
        glow = f"""<ellipse cx="76" cy="112" rx="24" ry="16" fill="{c['glow']}" opacity="0.32" filter="url(#glow)"/>"""
    return svg(f"""
  <g>
    <path d="M 36 92 C 48 86 60 96 76 91 C 92 86 104 96 114 90
             L 114 152 L 36 152 Z"
          fill="url(#amber)" stroke="none"/>
    <path d="M 36 92 C 48 86 60 96 76 91 C 92 86 104 96 114 90"
          fill="none" stroke="{c['liquid_hi']}" stroke-width="2.2" opacity="0.7" stroke-linecap="round"/>
    <ellipse cx="67" cy="110" rx="13" ry="3.5" fill="{c['liquid_hi']}" opacity="0.32"/>
    <ellipse cx="87" cy="122" rx="8" ry="2.6" fill="{c['liquid_hi']}" opacity="0.22"/>
    <circle cx="61" cy="128" r="2" fill="{c['liquid_hi']}" opacity="0.55"/>
    <circle cx="73" cy="119" r="1.4" fill="{c['liquid_hi']}" opacity="0.45"/>
    {glow}
  </g>""", c)


def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    for shape in range(3):
        with open(os.path.join(OUT, f"body{shape}.svg"), "w", encoding="utf-8") as f:
            f.write(body(shape))
        with open(os.path.join(OUT, f"base{shape}.svg"), "w", encoding="utf-8") as f:
            f.write(base(shape))
        with open(os.path.join(OUT, f"lid{shape}.svg"), "w", encoding="utf-8") as f:
            f.write(lid(shape))
        with open(os.path.join(OUT, f"liquid{shape}.svg"), "w", encoding="utf-8") as f:
            f.write(liquid(shape))
    for kind in range(4):
        with open(os.path.join(OUT, f"face{kind}.svg"), "w", encoding="utf-8") as f:
            f.write(face(kind))
    print(f"wrote SVG layers to {OUT}")


if __name__ == "__main__":
    main()
