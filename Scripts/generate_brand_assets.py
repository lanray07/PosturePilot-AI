from __future__ import annotations

import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "PosturePilotAI" / "Resources" / "Assets.xcassets"
MARKETING = ROOT / "Marketing" / "AppStore"

NAVY = (7, 16, 32)
SURFACE = (14, 28, 48)
SURFACE_2 = (20, 44, 70)
CYAN = (56, 219, 245)
TEAL = (32, 193, 169)
BLUE = (54, 88, 235)
AMBER = (255, 191, 78)
CORAL = (255, 92, 108)
WHITE = (242, 250, 255)
MUTED = (135, 168, 190)


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            pass
    return ImageFont.load_default()


def gradient(size: tuple[int, int], c1: tuple[int, int, int], c2: tuple[int, int, int], c3: tuple[int, int, int] | None = None) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size, c1)
    px = img.load()
    for y in range(h):
        for x in range(w):
            nx = x / max(1, w - 1)
            ny = y / max(1, h - 1)
            t = min(1.0, max(0.0, (nx * 0.55 + ny * 0.85)))
            if c3 and t > 0.55:
                tt = (t - 0.55) / 0.45
                base = tuple(int(c2[i] * (1 - tt) + c3[i] * tt) for i in range(3))
            else:
                tt = min(1.0, t / 0.55)
                base = tuple(int(c1[i] * (1 - tt) + c2[i] * tt) for i in range(3))
            px[x, y] = base
    return img.convert("RGBA")


def glow_layer(size: tuple[int, int], ellipses: list[tuple[tuple[int, int, int, int], tuple[int, int, int], int]]) -> Image.Image:
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for box, color, alpha in ellipses:
        draw.ellipse(box, fill=(*color, alpha))
    return layer.filter(ImageFilter.GaussianBlur(70))


def rounded_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill, outline=None, width: int = 1) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def add_noise(img: Image.Image, opacity: int = 14) -> Image.Image:
    w, h = img.size
    noise = Image.new("RGBA", img.size, (0, 0, 0, 0))
    px = noise.load()
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            value = (x * 17 + y * 31) % 255
            alpha = opacity if value > 228 else 0
            px[x, y] = (255, 255, 255, alpha)
    return Image.alpha_composite(img, noise)


def draw_score_ring(draw: ImageDraw.ImageDraw, center: tuple[int, int], radius: int, progress: float, width: int, label: str | None = None) -> None:
    x, y = center
    width = max(2, min(width, max(2, radius // 3)))
    box = (x - radius, y - radius, x + radius, y + radius)
    draw.arc(box, 0, 360, fill=(255, 255, 255, 38), width=width)
    draw.arc(box, -90, int(-90 + 360 * progress), fill=CYAN, width=width)
    inset = max(1, width)
    if box[2] - inset > box[0] + inset and box[3] - inset > box[1] + inset:
        draw.arc((box[0] + inset, box[1] + inset, box[2] - inset, box[3] - inset), -78, int(-78 + 220 * progress), fill=TEAL, width=max(1, width // 2))
    if label:
        f = font(max(18, radius // 2), True)
        bbox = draw.textbbox((0, 0), label, font=f)
        draw.text((x - (bbox[2] - bbox[0]) / 2, y - (bbox[3] - bbox[1]) / 2 - 3), label, fill=WHITE, font=f)


def draw_person(draw: ImageDraw.ImageDraw, x: int, y: int, scale: float, posture: str = "upright") -> None:
    head_r = int(34 * scale)
    torso_w = int(44 * scale)
    torso_h = int(140 * scale)
    if posture == "stretch":
        draw.line((x, y + head_r * 2, x - int(55 * scale), y + int(135 * scale)), fill=WHITE, width=int(12 * scale))
        draw.line((x, y + head_r * 2, x + int(75 * scale), y + int(90 * scale)), fill=WHITE, width=int(12 * scale))
        draw.line((x - int(52 * scale), y + int(125 * scale), x - int(105 * scale), y + int(200 * scale)), fill=TEAL, width=int(11 * scale))
        draw.line((x - int(52 * scale), y + int(125 * scale), x + int(14 * scale), y + int(214 * scale)), fill=CYAN, width=int(11 * scale))
        draw.line((x - int(14 * scale), y + int(76 * scale), x - int(94 * scale), y + int(10 * scale)), fill=CYAN, width=int(10 * scale))
        draw.line((x + int(8 * scale), y + int(78 * scale), x + int(94 * scale), y + int(16 * scale)), fill=TEAL, width=int(10 * scale))
    else:
        lean = int(18 * scale) if posture == "lean" else 0
        draw.line((x, y + head_r * 2, x - lean, y + head_r * 2 + torso_h), fill=WHITE, width=torso_w)
        draw.line((x - int(10 * scale), y + int(95 * scale), x - int(82 * scale), y + int(148 * scale)), fill=CYAN, width=int(11 * scale))
        draw.line((x + int(12 * scale), y + int(96 * scale), x + int(72 * scale), y + int(154 * scale)), fill=TEAL, width=int(11 * scale))
        draw.line((x - lean, y + head_r * 2 + torso_h, x - int(50 * scale), y + head_r * 2 + torso_h + int(78 * scale)), fill=BLUE, width=int(12 * scale))
        draw.line((x - lean, y + head_r * 2 + torso_h, x + int(54 * scale), y + head_r * 2 + torso_h + int(78 * scale)), fill=BLUE, width=int(12 * scale))
    draw.ellipse((x - head_r, y, x + head_r, y + head_r * 2), fill=(228, 244, 250), outline=(255, 255, 255, 70), width=max(2, int(2 * scale)))


def save_imageset(name: str, img: Image.Image) -> None:
    path = ASSETS / f"{name}.imageset"
    ensure_dir(path)
    filename = f"{name}.png"
    img.save(path / filename)
    contents = {
        "images": [{"idiom": "universal", "filename": filename, "scale": "1x"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"compression-type": "lossless"},
    }
    (path / "Contents.json").write_text(json.dumps(contents, indent=2), encoding="utf-8")


def make_hero() -> Image.Image:
    img = gradient((1600, 1100), NAVY, (5, 50, 78), (4, 10, 28))
    img = Image.alpha_composite(img, glow_layer(img.size, [((-260, -160, 620, 560), CYAN, 110), ((960, 90, 1900, 980), BLUE, 105), ((380, 620, 1260, 1280), TEAL, 70)]))
    draw = ImageDraw.Draw(img)

    rounded_rect(draw, (120, 132, 1480, 968), 54, (255, 255, 255, 16), (255, 255, 255, 44), 2)
    rounded_rect(draw, (1030, 220, 1368, 450), 28, (8, 22, 39, 218), (255, 255, 255, 55), 2)
    draw_score_ring(draw, (1130, 335), 72, 0.86, 12, "86")
    draw.text((1232, 290), "Posture", fill=WHITE, font=font(38, True))
    draw.text((1232, 340), "steady", fill=(*CYAN, 255), font=font(42, True))

    rounded_rect(draw, (190, 680, 610, 872), 30, (12, 26, 46, 230), (255, 255, 255, 52), 2)
    for i, label in enumerate(["screen height", "movement break", "shoulder reset"]):
        y = 724 + i * 46
        draw.ellipse((230, y, 252, y + 22), fill=TEAL if i != 1 else AMBER)
        draw.text((274, y - 6), label, fill=(213, 235, 246), font=font(29))

    desk_y = 725
    rounded_rect(draw, (500, desk_y, 1220, desk_y + 36), 18, (31, 207, 191, 190))
    rounded_rect(draw, (745, 390, 1115, 640), 24, (16, 36, 60, 245), (86, 231, 246, 120), 4)
    rounded_rect(draw, (782, 428, 1078, 590), 18, (31, 68, 96, 230), (255, 255, 255, 36), 2)
    draw.arc((820, 460, 1040, 680), 206, 334, fill=CYAN, width=8)
    draw.line((930, 640, 930, 724), fill=(177, 211, 224), width=12)
    draw.rectangle((810, 724, 1050, 744), fill=(177, 211, 224))
    rounded_rect(draw, (1115, 545, 1216, 726), 22, (14, 30, 50, 238), (255, 255, 255, 50), 2)
    draw.line((1140, 607, 1190, 607), fill=CYAN, width=5)
    draw.line((1140, 637, 1190, 637), fill=TEAL, width=5)
    draw_person(draw, 690, 378, 1.35)
    draw.arc((575, 350, 825, 720), 242, 300, fill=CYAN, width=8)
    draw.arc((570, 340, 838, 730), 242, 300, fill=(255, 255, 255, 70), width=2)
    return add_noise(img)


def make_camera() -> Image.Image:
    img = gradient((1400, 1000), (5, 13, 30), (7, 47, 73), (6, 9, 24))
    img = Image.alpha_composite(img, glow_layer(img.size, [((820, -80, 1540, 520), CYAN, 95), ((-220, 560, 520, 1160), BLUE, 90)]))
    draw = ImageDraw.Draw(img)
    rounded_rect(draw, (305, 86, 1095, 914), 64, (10, 22, 38, 248), (255, 255, 255, 58), 3)
    rounded_rect(draw, (356, 170, 1044, 808), 38, (13, 34, 55, 255), (79, 225, 245, 100), 4)
    for i in range(5):
        x = 420 + i * 120
        draw.line((x, 190, x, 788), fill=(255, 255, 255, 20), width=2)
    for i in range(4):
        y = 260 + i * 120
        draw.line((376, y, 1024, y), fill=(255, 255, 255, 18), width=2)
    draw_person(draw, 705, 300, 1.8, "lean")
    points = [(705, 365), (700, 455), (642, 520), (760, 530), (685, 630), (618, 742), (770, 746)]
    for x, y in points:
        draw.ellipse((x - 12, y - 12, x + 12, y + 12), fill=CYAN, outline=WHITE, width=2)
    for a, b in [(0, 1), (1, 2), (1, 3), (1, 4), (4, 5), (4, 6)]:
        draw.line((points[a][0], points[a][1], points[b][0], points[b][1]), fill=(65, 226, 245, 170), width=5)
    rounded_rect(draw, (820, 232, 988, 300), 22, (255, 191, 78, 225))
    draw.text((850, 247), "tilt?", fill=(24, 23, 25), font=font(28, True))
    rounded_rect(draw, (470, 720, 718, 778), 24, (32, 193, 169, 225))
    draw.text((500, 733), "possible slouch", fill=(5, 21, 25), font=font(25, True))
    draw_score_ring(draw, (955, 705), 70, 0.78, 12, "78")
    return add_noise(img)


def make_desk() -> Image.Image:
    img = gradient((1400, 1000), (5, 14, 28), (10, 43, 62), (5, 9, 23))
    img = Image.alpha_composite(img, glow_layer(img.size, [((120, 80, 680, 520), TEAL, 95), ((840, 430, 1600, 1160), BLUE, 100)]))
    draw = ImageDraw.Draw(img)
    rounded_rect(draw, (130, 170, 1270, 840), 46, (255, 255, 255, 14), (255, 255, 255, 42), 2)
    rounded_rect(draw, (358, 240, 790, 500), 28, (15, 36, 58, 245), (81, 224, 246, 110), 4)
    rounded_rect(draw, (395, 278, 753, 454), 18, (31, 76, 103, 235))
    draw.line((575, 504, 575, 622), fill=(202, 229, 237), width=14)
    draw.rectangle((430, 618, 720, 640), fill=(202, 229, 237))
    rounded_rect(draw, (240, 662, 1015, 710), 22, (31, 207, 191, 210))
    rounded_rect(draw, (498, 735, 760, 780), 22, (18, 37, 58, 245), (255, 255, 255, 44), 2)
    rounded_rect(draw, (805, 736, 928, 780), 22, (18, 37, 58, 245), (255, 255, 255, 44), 2)
    draw.arc((680, 532, 975, 920), 210, 315, fill=(213, 238, 246), width=20)
    draw.line((820, 636, 820, 796), fill=(213, 238, 246), width=18)
    for i, (x, y, label, color) in enumerate([
        (830, 284, "eye level", CYAN),
        (944, 522, "chair depth", TEAL),
        (1010, 720, "keyboard reach", AMBER),
        (290, 520, "soft light", BLUE),
    ]):
        rounded_rect(draw, (x, y, x + 260, y + 74), 22, (*color, 42), (*color, 170), 2)
        draw.ellipse((x + 18, y + 24, x + 40, y + 46), fill=color)
        draw.text((x + 54, y + 20), label, fill=WHITE, font=font(28, True))
    for x in range(210, 1190, 90):
        draw.line((x, 202, x + 58, 202), fill=(85, 225, 245, 70), width=3)
    return add_noise(img)


def make_focus() -> Image.Image:
    img = gradient((1400, 1000), (5, 12, 28), (24, 41, 76), (3, 8, 22))
    img = Image.alpha_composite(img, glow_layer(img.size, [((410, 140, 1000, 740), CYAN, 85), ((-170, 320, 470, 1100), AMBER, 55), ((980, -130, 1580, 450), BLUE, 105)]))
    draw = ImageDraw.Draw(img)
    draw_score_ring(draw, (700, 455), 210, 0.72, 28, "25")
    draw.text((630, 548), "min", fill=(170, 210, 226), font=font(48, True))
    for angle, label, color in [(20, "eyes", CYAN), (135, "stretch", TEAL), (250, "posture", AMBER), (310, "focus", BLUE)]:
        rad = math.radians(angle)
        x = int(700 + math.cos(rad) * 330)
        y = int(455 + math.sin(rad) * 260)
        rounded_rect(draw, (x - 120, y - 48, x + 120, y + 48), 26, (9, 22, 38, 230), (*color, 135), 2)
        draw.ellipse((x - 92, y - 15, x - 62, y + 15), fill=color)
        draw.text((x - 44, y - 18), label, fill=WHITE, font=font(29, True))
        draw.line((700, 455, x, y), fill=(*color, 60), width=3)
    rounded_rect(draw, (398, 790, 1002, 870), 28, (10, 25, 42, 230), (255, 255, 255, 48), 2)
    draw.text((470, 810), "Deep focus with gentle break cues", fill=(224, 244, 250), font=font(34, True))
    return add_noise(img)


def make_stretch() -> Image.Image:
    img = gradient((1400, 1000), (5, 14, 27), (6, 54, 62), (7, 9, 24))
    img = Image.alpha_composite(img, glow_layer(img.size, [((160, 120, 760, 760), TEAL, 105), ((860, 120, 1540, 880), CYAN, 82), ((-240, 660, 620, 1220), BLUE, 72)]))
    draw = ImageDraw.Draw(img)
    rounded_rect(draw, (170, 740, 1230, 800), 30, (31, 207, 191, 165))
    draw_person(draw, 660, 230, 1.9, "stretch")
    for box, start, end, color in [
        ((392, 130, 930, 710), 205, 330, CYAN),
        ((330, 85, 1010, 760), 212, 326, TEAL),
        ((272, 38, 1090, 812), 218, 322, BLUE),
    ]:
        draw.arc(box, start, end, fill=(*color, 210), width=8)
    rounded_rect(draw, (170, 180, 470, 312), 30, (10, 24, 41, 230), (255, 255, 255, 46), 2)
    draw.text((218, 210), "60 sec", fill=WHITE, font=font(45, True))
    draw.text((218, 264), "neck reset", fill=(168, 211, 224), font=font(26))
    rounded_rect(draw, (930, 612, 1208, 732), 30, (10, 24, 41, 230), (255, 255, 255, 46), 2)
    draw.text((980, 644), "breathe", fill=WHITE, font=font(38, True))
    draw.text((980, 690), "stand tall", fill=(168, 211, 224), font=font(25))
    return add_noise(img)


def make_paywall() -> Image.Image:
    img = gradient((1400, 1000), (6, 13, 28), (13, 34, 71), (4, 8, 22))
    img = Image.alpha_composite(img, glow_layer(img.size, [((430, -80, 1050, 560), AMBER, 80), ((-240, 300, 560, 1120), CYAN, 90), ((970, 430, 1580, 1060), BLUE, 90)]))
    draw = ImageDraw.Draw(img)
    plans = [("Free", "7-day history", 260, 300, MUTED), ("Pro", "AI insights", 540, 220, CYAN), ("Elite", "reports", 820, 300, AMBER)]
    for title, sub, x, y, color in plans:
        rounded_rect(draw, (x, y, x + 300, y + 460), 38, (9, 24, 42, 238), (*color, 150), 3)
        draw.ellipse((x + 98, y + 54, x + 202, y + 158), fill=(*color, 54), outline=(*color, 220), width=5)
        draw.text((x + 112, y + 82), title[:1], fill=WHITE, font=font(54, True))
        draw.text((x + 58, y + 190), title, fill=WHITE, font=font(48, True))
        draw.text((x + 58, y + 250), sub, fill=(180, 213, 226), font=font(28))
        for i in range(3):
            yy = y + 320 + i * 42
            draw.ellipse((x + 58, yy, x + 78, yy + 20), fill=color)
            draw.line((x + 96, yy + 10, x + 238, yy + 10), fill=(255, 255, 255, 58), width=6)
    draw_score_ring(draw, (700, 110), 72, 0.92, 12, "92")
    return add_noise(img)


def make_empty_state() -> Image.Image:
    img = gradient((900, 700), (6, 15, 28), (8, 44, 61), (3, 8, 20))
    img = Image.alpha_composite(img, glow_layer(img.size, [((180, 50, 760, 560), CYAN, 80)]))
    draw = ImageDraw.Draw(img)
    draw_score_ring(draw, (450, 300), 150, 0.80, 22, "AI")
    draw.arc((276, 180, 624, 554), 210, 330, fill=TEAL, width=9)
    rounded_rect(draw, (240, 520, 660, 590), 28, (10, 24, 41, 230), (255, 255, 255, 45), 2)
    draw.text((318, 538), "first check awaits", fill=WHITE, font=font(34, True))
    return add_noise(img)


def make_share_card() -> Image.Image:
    img = gradient((1200, 630), (5, 13, 29), (8, 49, 76), (5, 8, 22))
    img = Image.alpha_composite(img, glow_layer(img.size, [((-120, -120, 520, 500), CYAN, 110), ((700, 110, 1400, 760), BLUE, 92), ((350, 420, 1050, 850), TEAL, 66)]))
    draw = ImageDraw.Draw(img)

    icon = make_app_icon(128)
    img.alpha_composite(icon, (72, 70))
    draw.text((230, 84), "PosturePilot AI", fill=WHITE, font=font(50, True))
    draw.text((232, 142), "Posture habits for desk-heavy days", fill=(187, 221, 232), font=font(28))

    draw.text((76, 285), "I'm building a healthier", fill=WHITE, font=font(62, True))
    draw.text((76, 358), "desk routine.", fill=WHITE, font=font(62, True))
    draw.text((78, 450), "Posture checks, focus breaks, stretches,", fill=(196, 230, 240), font=font(29))
    draw.text((78, 490), "and ergonomic awareness.", fill=(196, 230, 240), font=font(29))

    rounded_rect(draw, (820, 110, 1094, 384), 48, (9, 24, 42, 235), (255, 255, 255, 58), 3)
    draw_score_ring(draw, (957, 247), 86, 0.88, 15, "88")
    rounded_rect(draw, (800, 430, 1124, 524), 28, (10, 24, 41, 230), (*TEAL, 150), 2)
    draw.ellipse((838, 460, 864, 486), fill=TEAL)
    draw.text((884, 452), "Try a reset", fill=WHITE, font=font(34, True))
    return add_noise(img)


def make_app_icon(size: int) -> Image.Image:
    img = gradient((size, size), (3, 13, 31), (3, 64, 86), (10, 18, 46))
    img = Image.alpha_composite(img, glow_layer(img.size, [((-size // 4, -size // 4, size * 3 // 4, size * 3 // 4), CYAN, 120), ((size // 3, size // 2, size * 5 // 4, size * 5 // 4), BLUE, 120)]))
    draw = ImageDraw.Draw(img)
    pad = int(size * 0.12)
    rounded_rect(draw, (pad, pad, size - pad, size - pad), int(size * 0.20), (255, 255, 255, 18), (255, 255, 255, 52), max(2, size // 180))
    center = (size // 2, size // 2)
    draw_score_ring(draw, center, int(size * 0.31), 0.86, max(10, size // 30))
    spine_x = size // 2
    top = int(size * 0.29)
    bottom = int(size * 0.68)
    width = max(8, size // 48)
    draw.line((spine_x, top, spine_x - int(size * 0.025), bottom), fill=WHITE, width=width)
    for i in range(5):
        y = top + int((bottom - top) * i / 4)
        dx = int(size * (0.06 + i * 0.006))
        draw.arc((spine_x - dx, y - int(size * 0.04), spine_x + dx, y + int(size * 0.04)), 200, 340, fill=CYAN if i % 2 else TEAL, width=max(4, size // 80))
    draw.ellipse((spine_x - int(size * 0.07), int(size * 0.19), spine_x + int(size * 0.07), int(size * 0.33)), fill=WHITE)
    draw.polygon(
        [
            (int(size * 0.70), int(size * 0.22)),
            (int(size * 0.75), int(size * 0.33)),
            (int(size * 0.86), int(size * 0.36)),
            (int(size * 0.76), int(size * 0.42)),
            (int(size * 0.75), int(size * 0.54)),
            (int(size * 0.68), int(size * 0.44)),
            (int(size * 0.56), int(size * 0.43)),
            (int(size * 0.66), int(size * 0.35)),
        ],
        fill=(*AMBER, 230),
    )
    return img


def paste_cover(canvas: Image.Image, image: Image.Image, box: tuple[int, int, int, int]) -> None:
    target_w = box[2] - box[0]
    target_h = box[3] - box[1]
    scale = max(target_w / image.width, target_h / image.height)
    resized = image.resize((int(image.width * scale), int(image.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - target_w) // 2
    top = (resized.height - target_h) // 2
    cropped = resized.crop((left, top, left + target_w, top + target_h))
    canvas.alpha_composite(cropped, (box[0], box[1]))


def draw_marketing_phone(draw: ImageDraw.ImageDraw, canvas: Image.Image, box: tuple[int, int, int, int], art: Image.Image) -> None:
    x0, y0, x1, y1 = box
    rounded_rect(draw, box, 76, (8, 18, 32, 255), (255, 255, 255, 95), 4)
    screen = (x0 + 38, y0 + 78, x1 - 38, y1 - 78)
    rounded_rect(draw, screen, 44, (14, 28, 48, 255))
    mask = Image.new("L", (screen[2] - screen[0], screen[3] - screen[1]), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, mask.width, mask.height), radius=44, fill=255)
    screen_art = Image.new("RGBA", mask.size, (0, 0, 0, 0))
    paste_cover(screen_art, art, (0, 0, mask.width, mask.height))
    clipped = Image.new("RGBA", mask.size, (0, 0, 0, 0))
    clipped.paste(screen_art, (0, 0), mask)
    canvas.alpha_composite(clipped, (screen[0], screen[1]))
    rounded_rect(draw, (x0 + 260, y0 + 28, x1 - 260, y0 + 52), 12, (255, 255, 255, 65))


def make_marketing_poster(filename: str, headline: str, subline: str, art: Image.Image, accent: tuple[int, int, int]) -> None:
    ensure_dir(MARKETING)
    img = gradient((1290, 2796), (5, 13, 29), (7, 45, 70), (4, 7, 20))
    img = Image.alpha_composite(img, glow_layer(img.size, [((-300, 130, 1050, 1200), accent, 115), ((640, 1650, 1680, 2900), BLUE, 95)]))
    draw = ImageDraw.Draw(img)

    icon = make_app_icon(188)
    img.alpha_composite(icon, (110, 128))
    draw.text((330, 150), "PosturePilot AI", fill=WHITE, font=font(58, True))
    draw.text((330, 220), "Wellness posture habits", fill=(187, 221, 232), font=font(34))

    y = 450
    max_width = 1020
    lines = wrap_text(draw, headline, font(92, True), max_width)
    headline_font = font(92, True)
    for line in lines:
        draw.text((110, y), line, fill=WHITE, font=headline_font)
        y += 108

    subline_font = font(42)
    for line in wrap_text(draw, subline, subline_font, max_width):
        draw.text((112, y + 32), line, fill=(193, 226, 236), font=subline_font)
        y += 54
    draw_marketing_phone(draw, img, (245, 1050, 1045, 2460), art)
    rounded_rect(draw, (160, 2505, 1130, 2636), 40, (9, 24, 42, 225), (*accent, 130), 2)
    draw.text((220, 2532), "Informational wellness insights, not medical advice", fill=(224, 244, 250), font=font(36, True))
    img = add_noise(img, 10)
    img.save(MARKETING / filename)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, text_font: ImageFont.ImageFont, max_width: int) -> list[str]:
    words = text.split()
    lines = []
    current = ""
    for word in words:
        trial = f"{current} {word}".strip()
        if draw.textlength(trial, font=text_font) <= max_width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def save_marketing_assets() -> None:
    make_marketing_poster(
        "posturepilot-appstore-01-posture-checks.png",
        "Posture checks for desk days",
        "Mock AI posture analysis, sitting awareness, and gentle correction cues.",
        make_camera(),
        CYAN,
    )
    make_marketing_poster(
        "posturepilot-appstore-02-focus-breaks.png",
        "Focus without forgetting breaks",
        "Work, study, gaming, and deep focus modes with recovery prompts.",
        make_focus(),
        TEAL,
    )
    make_marketing_poster(
        "posturepilot-appstore-03-desk-setup.png",
        "Make your workspace feel better",
        "Ergonomics suggestions for monitor height, lighting, and desk setup.",
        make_desk(),
        AMBER,
    )


def app_icon_contents(entries: list[tuple[str, str, str, str]]) -> dict:
    return {
        "images": [
            {"size": size, "idiom": idiom, "filename": filename, "scale": scale}
            for idiom, size, scale, filename in entries
        ],
        "info": {"author": "xcode", "version": 1},
    }


def save_app_icons() -> None:
    path = ASSETS / "AppIcon.appiconset"
    ensure_dir(path)
    specs = [
        ("iphone", "20x20", "2x", 40), ("iphone", "20x20", "3x", 60),
        ("iphone", "29x29", "2x", 58), ("iphone", "29x29", "3x", 87),
        ("iphone", "40x40", "2x", 80), ("iphone", "40x40", "3x", 120),
        ("iphone", "60x60", "2x", 120), ("iphone", "60x60", "3x", 180),
        ("ipad", "20x20", "1x", 20), ("ipad", "20x20", "2x", 40),
        ("ipad", "29x29", "1x", 29), ("ipad", "29x29", "2x", 58),
        ("ipad", "40x40", "1x", 40), ("ipad", "40x40", "2x", 80),
        ("ipad", "76x76", "1x", 76), ("ipad", "76x76", "2x", 152),
        ("ipad", "83.5x83.5", "2x", 167),
        ("ios-marketing", "1024x1024", "1x", 1024),
    ]
    entries = []
    for idiom, logical_size, scale, pixel_size in specs:
        filename = f"AppIcon-{idiom}-{logical_size.replace('.', '_')}@{scale}.png"
        make_app_icon(pixel_size).save(path / filename)
        entries.append((idiom, logical_size, scale, filename))
    (path / "Contents.json").write_text(json.dumps(app_icon_contents(entries), indent=2), encoding="utf-8")


def main() -> None:
    ensure_dir(ASSETS)
    save_app_icons()
    save_imageset("HeroPosture", make_hero())
    save_imageset("CameraPostureVisual", make_camera())
    save_imageset("DeskScanVisual", make_desk())
    save_imageset("FocusFlowVisual", make_focus())
    save_imageset("StretchRecoveryVisual", make_stretch())
    save_imageset("PremiumPlansVisual", make_paywall())
    save_imageset("PostureEmptyVisual", make_empty_state())
    save_imageset("ShareCardVisual", make_share_card())
    save_marketing_assets()
    print(f"Generated brand assets in {ASSETS}")
    print(f"Generated marketing assets in {MARKETING}")


if __name__ == "__main__":
    main()
