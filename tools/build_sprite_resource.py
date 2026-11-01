#!/usr/bin/env python3
"""Build a GameMaker sprite resource (.yy + frame/layer PNGs) from source frames.

Pixel-art example (32x32 source frames, 3x nearest upscale -> 96x96):
  python tools/build_sprite_resource.py --name spr_my_plant \
    --src art/my_plant --frames 8 --pixel-scale 3 \
    --origin bottom --texture-group cards \
    --folder "folders/精灵/Cards/Assistant/my_plant"

Smooth-art example (source frames already at final size):
  python tools/build_sprite_resource.py --name spr_my_plant_icon \
    --src art/my_plant_icon --frames 1 --pixel-scale 1 \
    --origin custom --origin-x 45 --origin-y 95 --texture-group UI \
    --folder "folders/精灵/Cards/Assistant/my_plant"

The script does NOT draw the art. It only packages already-drawn frames into
the folder structure and .yy format GameMaker expects, then prints the lines
to paste into FVM-reborn.yyp.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
import uuid

from PIL import Image


def new_uuid() -> str:
    return str(uuid.uuid4())


def natural_key(path: str):
    name = os.path.splitext(os.path.basename(path))[0]
    return [int(part) if part.isdigit() else part.lower()
            for part in re.split(r"(\d+)", name)]


def discover_frames(src: str, frames: int | None) -> list[str]:
    if frames is not None:
        candidates = [
            [os.path.join(src, f"{i}.png") for i in range(frames)],
            [os.path.join(src, f"frame_{i}.png") for i in range(frames)],
        ]
        for paths in candidates:
            if all(os.path.exists(p) for p in paths):
                return paths
        raise SystemExit(
            f"expected {frames} frames named 0.png..{frames - 1}.png "
            f"or frame_0.png..frame_{frames - 1}.png in {src}"
        )

    paths = sorted((p for p in
                    (os.path.join(src, f) for f in os.listdir(src))
                    if p.lower().endswith(".png")), key=natural_key)
    if not paths:
        raise SystemExit(f"no PNG frames found in {src}")
    return paths


def load_frames(paths: list[str], pixel_scale: int) -> list[Image.Image]:
    frames = []
    for path in paths:
        im = Image.open(path).convert("RGBA")
        if pixel_scale > 1:
            im = im.resize((im.width * pixel_scale, im.height * pixel_scale),
                           Image.NEAREST)
        frames.append(im)
    size = frames[0].size
    for i, im in enumerate(frames):
        if im.size != size:
            raise SystemExit(
                f"frame {paths[i]} is {im.size}, expected {size} "
                f"(all frames must match)"
            )
    return frames


def alpha_bbox(frames: list[Image.Image], size: tuple[int, int]):
    left, top = size[0], size[1]
    right = bottom = -1
    for im in frames:
        box = im.getchannel("A").getbbox()
        if box is None:
            continue
        left = min(left, box[0])
        top = min(top, box[1])
        right = max(right, box[2] - 1)
        bottom = max(bottom, box[3] - 1)
    if right < 0:
        return 0, 0, size[0] - 1, size[1] - 1
    return left, top, right, bottom


def make_sprite_yy(name, width, height, frame_ids, layer_id, origin,
                   origin_x, origin_y, playback_speed, texture_group, folder,
                   bbox):
    keyframes = []
    for i, fid in enumerate(frame_ids):
        keyframes.append({
            "$Keyframe<SpriteFrameKeyframe>": "",
            "Channels": {
                "0": {
                    "$SpriteFrameKeyframe": "",
                    "Id": {
                        "name": fid,
                        "path": f"sprites/{name}/{name}.yy",
                    },
                    "resourceType": "SpriteFrameKeyframe",
                    "resourceVersion": "2.0",
                }
            },
            "Disabled": False,
            "id": new_uuid(),
            "IsCreationKey": False,
            "Key": float(i),
            "Length": 1.0,
            "resourceType": "Keyframe<SpriteFrameKeyframe>",
            "resourceVersion": "2.0",
            "Stretch": False,
        })

    folder = folder.rstrip("/")
    if folder.endswith(".yy"):
        folder = folder[:-3]
    folder_name = folder.rsplit("/", 1)[-1]

    return {
        "$GMSprite": "v2",
        "%Name": name,
        "bboxMode": 0,
        "bbox_bottom": bbox[3],
        "bbox_left": bbox[0],
        "bbox_right": bbox[2],
        "bbox_top": bbox[1],
        "collisionKind": 1,
        "collisionTolerance": 0,
        "DynamicTexturePage": False,
        "edgeFiltering": False,
        "For3D": False,
        "frames": [{
            "$GMSpriteFrame": "v1",
            "%Name": fid,
            "name": fid,
            "resourceType": "GMSpriteFrame",
            "resourceVersion": "2.0",
        } for fid in frame_ids],
        "gridX": 0,
        "gridY": 0,
        "height": height,
        "HTile": False,
        "layers": [{
            "$GMImageLayer": "",
            "%Name": layer_id,
            "blendMode": 0,
            "displayName": "default",
            "isLocked": False,
            "name": layer_id,
            "opacity": 100.0,
            "resourceType": "GMImageLayer",
            "resourceVersion": "2.0",
            "visible": True,
        }],
        "name": name,
        "nineSlice": None,
        "origin": origin,
        "parent": {
            "name": folder_name,
            "path": folder + ".yy",
        },
        "preMultiplyAlpha": False,
        "resourceType": "GMSprite",
        "resourceVersion": "2.0",
        "sequence": {
            "$GMSequence": "v1",
            "%Name": name,
            "autoRecord": True,
            "backdropHeight": 768,
            "backdropImageOpacity": 0.5,
            "backdropImagePath": "",
            "backdropWidth": 1366,
            "backdropXOffset": 0.0,
            "backdropYOffset": 0.0,
            "events": {
                "$KeyframeStore<MessageEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MessageEventKeyframe>",
                "resourceVersion": "2.0",
            },
            "eventStubScript": None,
            "eventToFunction": {},
            "length": float(len(frame_ids)),
            "lockOrigin": False,
            "moments": {
                "$KeyframeStore<MomentsEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MomentsEventKeyframe>",
                "resourceVersion": "2.0",
            },
            "name": name,
            "playback": 1,
            "playbackSpeed": float(playback_speed),
            "playbackSpeedType": 0,
            "resourceType": "GMSequence",
            "resourceVersion": "2.0",
            "showBackdrop": True,
            "showBackdropImage": False,
            "timeUnits": 1,
            "tracks": [{
                "$GMSpriteFramesTrack": "",
                "builtinName": 0,
                "events": [],
                "inheritsTrackColour": True,
                "interpolation": 1,
                "isCreationTrack": False,
                "keyframes": {
                    "$KeyframeStore<SpriteFrameKeyframe>": "",
                    "Keyframes": keyframes,
                    "resourceType": "KeyframeStore<SpriteFrameKeyframe>",
                    "resourceVersion": "2.0",
                },
                "modifiers": [],
                "name": "frames",
                "resourceType": "GMSpriteFramesTrack",
                "resourceVersion": "2.0",
                "spriteId": None,
                "trackColour": 0,
                "tracks": [],
                "traits": 0,
            }],
            "visibleRange": None,
            "volume": 1.0,
            "xorigin": origin_x,
            "yorigin": origin_y,
        },
        "swatchColours": None,
        "swfPrecision": 0.5,
        "textureGroupId": {
            "name": texture_group,
            "path": f"texturegroups/{texture_group}",
        },
        "type": 0,
        "VTile": False,
        "width": width,
    }


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", default=".", help="repo root (default: .)")
    parser.add_argument("--name", required=True, help="sprite resource name, e.g. spr_my_plant")
    parser.add_argument("--src", required=True, help="directory containing source PNG frames")
    parser.add_argument("--frames", type=int, default=None,
                        help="frame count; if omitted, all PNGs in --src are used in natural order")
    parser.add_argument("--pixel-scale", type=int, default=1,
                        help="integer nearest-neighbour upscale for pixel art (default: 1)")
    parser.add_argument("--origin", choices=["bottom", "custom"], default="bottom",
                        help="bottom = origin 7; custom requires --origin-x/--origin-y")
    parser.add_argument("--origin-x", type=float, default=None)
    parser.add_argument("--origin-y", type=float, default=None)
    parser.add_argument("--texture-group", default="cards",
                        help="GameMaker texture group (cards for plants, UI for card icons)")
    parser.add_argument("--folder", required=True,
                        help='GameMaker folder path without .yy, e.g. "folders/精灵/Cards/Assistant/my_plant"')
    parser.add_argument("--playback-speed", type=float, default=12.0)
    parser.add_argument("--overwrite", action="store_true",
                        help="delete an existing sprites/<name> directory first")
    args = parser.parse_args(argv)

    root = os.path.abspath(args.root)
    src = os.path.abspath(args.src)
    sprite_dir = os.path.join(root, "sprites", args.name)

    if not os.path.isdir(src):
        raise SystemExit(f"source directory not found: {src}")
    if os.path.exists(sprite_dir):
        if not args.overwrite:
            raise SystemExit(f"{sprite_dir} already exists; pass --overwrite to replace it")
        shutil.rmtree(sprite_dir)
    os.makedirs(os.path.join(sprite_dir, "layers"), exist_ok=True)

    paths = discover_frames(src, args.frames)
    frames = load_frames(paths, args.pixel_scale)
    width, height = frames[0].size
    bbox = alpha_bbox(frames, (width, height))

    if args.origin == "bottom":
        origin = 7
        origin_x = width // 2
        origin_y = height
    else:
        if args.origin_x is None or args.origin_y is None:
            raise SystemExit("--origin custom requires --origin-x and --origin-y")
        origin = 9
        # GameMaker requires integer origins in sprite .yy files.
        origin_x = int(round(args.origin_x))
        origin_y = int(round(args.origin_y))

    layer_id = new_uuid()
    frame_ids = []
    for im in frames:
        fid = new_uuid()
        frame_ids.append(fid)
        im.save(os.path.join(sprite_dir, fid + ".png"))
        frame_layer_dir = os.path.join(sprite_dir, "layers", fid)
        os.makedirs(frame_layer_dir, exist_ok=True)
        im.save(os.path.join(frame_layer_dir, layer_id + ".png"))

    yy = make_sprite_yy(args.name, width, height, frame_ids, layer_id, origin,
                        origin_x, origin_y, args.playback_speed,
                        args.texture_group, args.folder, bbox)
    with open(os.path.join(sprite_dir, args.name + ".yy"), "w", encoding="utf-8") as f:
        json.dump(yy, f, ensure_ascii=False, indent=2)
        f.write("\n")

    folder = args.folder.rstrip("/")
    if folder.endswith(".yy"):
        folder = folder[:-3]
    folder_name = folder.rsplit("/", 1)[-1]

    print(f"wrote {sprite_dir} ({width}x{height}, {len(frames)} frame(s))")
    print()
    print("Add to FVM-reborn.yyp resources:")
    print(f'    {{"id":{{"name":"{args.name}","path":"sprites/{args.name}/{args.name}.yy",}},}},')
    print()
    print("If the folder is new, add to FVM-reborn.yyp Folders:")
    print(f'    {{"$GMFolder":"","%Name":"{folder_name}","folderPath":"{folder}.yy","name":"{folder_name}","resourceType":"GMFolder","resourceVersion":"2.0",}},')


if __name__ == "__main__":
    main()
