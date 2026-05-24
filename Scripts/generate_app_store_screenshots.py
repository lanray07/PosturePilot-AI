from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

from generate_brand_assets import (
    AMBER,
    BLUE,
    CYAN,
    NAVY,
    TEAL,
    WHITE,
    add_noise,
    draw_score_ring,
    font,
    glow_layer,
    gradient,
    make_app_icon,
    make_camera,
    make_desk,
    make_focus,
    make_hero,
    make_paywall,
    make_stretch,
    rounded_rect,
    wrap_text,
)


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Marketing" / "AppStoreConnect"

IPHONE_65 = (1242, 2688)
IPAD_129 = (2048, 2732)
SQUARE = (1080, 1080)


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def text_block(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    max_width: int,
    text_font: ImageFont.ImageFont,
    fill=WHITE,
    line_gap: int = 8,
) -> int:
    x, y = xy
    for line in wrap_text(draw, text, text_font, max_width):
        draw.text((x, y), line, fill=fill, font=text_font)
        bbox = draw.textbbox((x, y), line, font=text_font)
        y = bbox[3] + line_gap
    return y


def draw_header(draw: ImageDraw.ImageDraw, canvas: Image.Image, title: str, subtitle: str, width: int, top: int, scale: float) -> int:
    icon_size = int(108 * scale)
    canvas.alpha_composite(make_app_icon(icon_size), (int(74 * scale), top))
    draw.text((int(74 * scale) + icon_size + int(28 * scale), top + int(9 * scale)), "PosturePilot AI", fill=WHITE, font=font(int(39 * scale), True))
    draw.text((int(74 * scale) + icon_size + int(28 * scale), top + int(58 * scale)), "Wellness posture habits", fill=(190, 222, 233), font=font(int(25 * scale)))
    y = top + int(170 * scale)
    y = text_block(draw, (int(74 * scale), y), title, width - int(148 * scale), font(int(76 * scale), True), WHITE, int(8 * scale))
    y += int(18 * scale)
    return text_block(draw, (int(78 * scale), y), subtitle, width - int(156 * scale), font(int(34 * scale)), (196, 230, 240), int(9 * scale))


def paste_cover(canvas: Image.Image, image: Image.Image, box: tuple[int, int, int, int], radius: int = 0) -> None:
    target_w = box[2] - box[0]
    target_h = box[3] - box[1]
    scale = max(target_w / image.width, target_h / image.height)
    resized = image.resize((int(image.width * scale), int(image.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - target_w) // 2
    top = (resized.height - target_h) // 2
    cropped = resized.crop((left, top, left + target_w, top + target_h))
    if radius:
        mask = Image.new("L", (target_w, target_h), 0)
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, target_w, target_h), radius=radius, fill=255)
        layer = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
        layer.paste(cropped, (0, 0), mask)
        canvas.alpha_composite(layer, (box[0], box[1]))
    else:
        canvas.alpha_composite(cropped, (box[0], box[1]))


def draw_phone_frame(canvas: Image.Image, draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], art: Image.Image, scale: float) -> None:
    x0, y0, x1, y1 = box
    radius = int(72 * scale)
    rounded_rect(draw, box, radius, (8, 18, 32, 255), (255, 255, 255, 105), max(2, int(3 * scale)))
    screen = (x0 + int(38 * scale), y0 + int(78 * scale), x1 - int(38 * scale), y1 - int(78 * scale))
    rounded_rect(draw, screen, int(42 * scale), (14, 28, 48, 255))
    paste_cover(canvas, art, screen, int(42 * scale))
    rounded_rect(draw, (x0 + int(260 * scale), y0 + int(28 * scale), x1 - int(260 * scale), y0 + int(52 * scale)), int(12 * scale), (255, 255, 255, 66))


def draw_ipad_frame(canvas: Image.Image, draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], art: Image.Image, scale: float) -> None:
    x0, y0, x1, y1 = box
    rounded_rect(draw, box, int(54 * scale), (8, 18, 32, 255), (255, 255, 255, 95), max(2, int(3 * scale)))
    screen = (x0 + int(44 * scale), y0 + int(58 * scale), x1 - int(44 * scale), y1 - int(58 * scale))
    rounded_rect(draw, screen, int(34 * scale), (14, 28, 48, 255))
    paste_cover(canvas, art, screen, int(34 * scale))


def feature_chips(draw: ImageDraw.ImageDraw, chips: list[tuple[str, tuple[int, int, int]]], x: int, y: int, scale: float) -> None:
    for text, color in chips:
        chip_w = int(45 * scale + draw.textlength(text, font=font(int(25 * scale), True)))
        rounded_rect(draw, (x, y, x + chip_w, y + int(56 * scale)), int(24 * scale), (*color, 36), (*color, 150), max(1, int(2 * scale)))
        draw.ellipse((x + int(18 * scale), y + int(19 * scale), x + int(36 * scale), y + int(37 * scale)), fill=color)
        draw.text((x + int(48 * scale), y + int(12 * scale)), text, fill=WHITE, font=font(int(25 * scale), True))
        y += int(70 * scale)


def app_store_screen(
    size: tuple[int, int],
    filename: Path,
    title: str,
    subtitle: str,
    art: Image.Image,
    chips: list[tuple[str, tuple[int, int, int]]],
    accent: tuple[int, int, int],
    device: str,
) -> None:
    w, h = size
    scale = w / 1242
    img = gradient(size, (5, 13, 29), (7, 45, 70), (4, 7, 20))
    img = Image.alpha_composite(img, glow_layer(size, [((-250, 120, int(w * 0.95), int(h * 0.46)), accent, 112), ((int(w * 0.48), int(h * 0.56), int(w * 1.30), int(h * 1.08)), BLUE, 92)]))
    draw = ImageDraw.Draw(img)
    y = draw_header(draw, img, title, subtitle, w, int(112 * scale), scale)
    y += int(32 * scale)
    feature_chips(draw, chips, int(80 * scale), y, scale)

    if device == "iphone":
        phone_w = int(720 * scale)
        phone_h = int(1290 * scale)
        box = ((w - phone_w) // 2, h - phone_h - int(174 * scale), (w + phone_w) // 2, h - int(174 * scale))
        draw_phone_frame(img, draw, box, art, scale)
    else:
        ipad_w = int(w * 0.79)
        ipad_h = int(h * 0.50)
        box = ((w - ipad_w) // 2, h - ipad_h - int(190 * scale), (w + ipad_w) // 2, h - int(190 * scale))
        draw_ipad_frame(img, draw, box, art, scale)

    rounded_rect(draw, (int(110 * scale), h - int(126 * scale), w - int(110 * scale), h - int(58 * scale)), int(28 * scale), (9, 24, 42, 225), (*accent, 130), max(1, int(2 * scale)))
    disclaimer = "Informational wellness insights, not medical advice"
    disclaimer_font = font(int(27 * scale), True)
    disclaimer_w = draw.textlength(disclaimer, font=disclaimer_font)
    draw.text(((w - disclaimer_w) / 2, h - int(107 * scale)), disclaimer, fill=(224, 244, 250), font=disclaimer_font)
    ensure_dir(filename.parent)
    add_noise(img, 10).convert("RGB").save(filename, quality=96)


def draw_subscription_card(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], title: str, price: str, features: list[str], color, scale: float, featured: bool = False) -> None:
    fill = (10, 24, 42, 238)
    outline = (*color, 210 if featured else 120)
    rounded_rect(draw, box, int(34 * scale), fill, outline, max(2, int(3 * scale)))
    x0, y0, x1, _ = box
    if featured:
        rounded_rect(draw, (x0 + int(30 * scale), y0 - int(24 * scale), x0 + int(224 * scale), y0 + int(26 * scale)), int(19 * scale), (*color, 245))
        draw.text((x0 + int(58 * scale), y0 - int(16 * scale)), "BEST VALUE", fill=(5, 14, 23), font=font(int(20 * scale), True))
    draw.text((x0 + int(42 * scale), y0 + int(46 * scale)), title, fill=WHITE, font=font(int(44 * scale), True))
    draw.text((x0 + int(42 * scale), y0 + int(104 * scale)), price, fill=color, font=font(int(42 * scale), True))
    y = y0 + int(180 * scale)
    for feature in features:
        draw.ellipse((x0 + int(44 * scale), y + int(9 * scale), x0 + int(64 * scale), y + int(29 * scale)), fill=color)
        draw.text((x0 + int(82 * scale), y), feature, fill=(206, 234, 242), font=font(int(25 * scale)))
        y += int(48 * scale)


def subscription_screen(size: tuple[int, int], filename: Path, focus: str, accent) -> None:
    w, h = size
    scale = w / 1242
    img = gradient(size, (5, 13, 29), (24, 27, 58), (4, 7, 20))
    img = Image.alpha_composite(img, glow_layer(size, [((int(w * 0.18), -120, int(w * 0.95), int(h * 0.38)), AMBER, 84), ((-240, int(h * 0.34), int(w * 0.58), int(h * 0.98)), CYAN, 88)]))
    draw = ImageDraw.Draw(img)
    draw_header(draw, img, "Unlock premium posture intelligence", "AI insights, unlimited focus sessions, ergonomics scans, and productivity-aware reports.", w, int(112 * scale), scale)
    card_y = int(780 * scale)
    card_h = int(360 * scale)
    gap = int(32 * scale)
    plans = [
        ("Free", "£0", ["Basic tracking", "Limited reminders", "7-day history"], (135, 168, 190), False),
        ("Pro", "£7.99/mo", ["AI posture analysis", "Unlimited focus", "Ergonomics scanner"], CYAN, focus == "pro"),
        ("Elite", "£14.99/mo", ["Advanced AI", "Detailed reports", "Premium themes"], AMBER, focus == "elite"),
    ]
    for i, (title, price, features, color, featured) in enumerate(plans):
        y = card_y + i * (card_h + gap)
        draw_subscription_card(
            draw,
            (int(104 * scale), y, w - int(104 * scale), y + card_h),
            title,
            price,
            features,
            color,
            scale,
            featured,
        )
    paste_cover(img, make_paywall(), (int(184 * scale), h - int(604 * scale), w - int(184 * scale), h - int(158 * scale)), int(42 * scale))
    ensure_dir(filename.parent)
    add_noise(img, 10).convert("RGB").save(filename, quality=96)


def review_card(size: tuple[int, int], filename: Path, quote: str, role: str, accent, square: bool = False) -> None:
    w, h = size
    scale = w / 1080 if square else w / 1242
    img = gradient(size, (5, 13, 29), (6, 42, 64), (4, 7, 20))
    img = Image.alpha_composite(img, glow_layer(size, [((-220, 80, int(w * 0.78), int(h * 0.70)), accent, 100), ((int(w * 0.42), int(h * 0.45), int(w * 1.24), int(h * 1.1)), BLUE, 88)]))
    draw = ImageDraw.Draw(img)
    icon = make_app_icon(int(112 * scale))
    img.alpha_composite(icon, (int(76 * scale), int(72 * scale)))
    draw.text((int(212 * scale), int(88 * scale)), "PosturePilot AI", fill=WHITE, font=font(int(42 * scale), True))
    draw.text((int(214 * scale), int(142 * scale)), "Desk wellness habits", fill=(190, 222, 233), font=font(int(26 * scale)))

    card = (int(82 * scale), int(260 * scale), w - int(82 * scale), h - int(154 * scale))
    rounded_rect(draw, card, int(44 * scale), (9, 24, 42, 230), (255, 255, 255, 58), max(2, int(2 * scale)))
    for i in range(5):
        cx = card[0] + int((72 + i * 48) * scale)
        cy = card[1] + int(72 * scale)
        draw.polygon(
            [
                (cx, cy - int(22 * scale)),
                (cx + int(8 * scale), cy - int(6 * scale)),
                (cx + int(26 * scale), cy - int(5 * scale)),
                (cx + int(12 * scale), cy + int(7 * scale)),
                (cx + int(17 * scale), cy + int(25 * scale)),
                (cx, cy + int(15 * scale)),
                (cx - int(17 * scale), cy + int(25 * scale)),
                (cx - int(12 * scale), cy + int(7 * scale)),
                (cx - int(26 * scale), cy - int(5 * scale)),
                (cx - int(8 * scale), cy - int(6 * scale)),
            ],
            fill=AMBER,
        )
    quote_font = font(int(54 * scale), True)
    text_block(draw, (card[0] + int(62 * scale), card[1] + int(150 * scale)), quote, card[2] - card[0] - int(124 * scale), quote_font, WHITE, int(14 * scale))

    if not square:
        ring_y = card[1] + int(760 * scale)
        draw_score_ring(draw, (w // 2, ring_y), int(154 * scale), 0.88, int(22 * scale), "88")
        draw.text((card[0] + int(140 * scale), ring_y + int(210 * scale)), "Posture checks", fill=CYAN, font=font(int(34 * scale), True))
        draw.text((card[0] + int(140 * scale), ring_y + int(260 * scale)), "Focus breaks", fill=TEAL, font=font(int(34 * scale), True))
        draw.text((card[0] + int(140 * scale), ring_y + int(310 * scale)), "Stretch resets", fill=AMBER, font=font(int(34 * scale), True))
        for i, color in enumerate([CYAN, TEAL, AMBER]):
            y = ring_y + int((222 + i * 50) * scale)
            draw.ellipse((card[0] + int(98 * scale), y, card[0] + int(122 * scale), y + int(24 * scale)), fill=color)

        rounded_rect(
            draw,
            (card[0] + int(92 * scale), card[3] - int(300 * scale), card[2] - int(92 * scale), card[3] - int(168 * scale)),
            int(34 * scale),
            (10, 24, 42, 245),
            (*accent, 128),
            max(2, int(2 * scale)),
        )
        draw.text((card[0] + int(136 * scale), card[3] - int(264 * scale)), "Designed for desk-heavy days", fill=WHITE, font=font(int(35 * scale), True))
        draw.text((card[0] + int(136 * scale), card[3] - int(214 * scale)), "Remote work, study, gaming, coding, and creating.", fill=(190, 222, 233), font=font(int(25 * scale)))

    draw.text((card[0] + int(62 * scale), card[3] - int(106 * scale)), role, fill=(190, 222, 233), font=font(int(30 * scale), True))
    draw.text((int(92 * scale), h - int(92 * scale)), "Informational wellness app - not medical advice", fill=(203, 232, 241), font=font(int(25 * scale), True))
    ensure_dir(filename.parent)
    add_noise(img, 10).convert("RGB").save(filename, quality=96)


def save_app_store_connect_screenshots() -> None:
    iphone_dir = OUT / "iPhone-6.5"
    ipad_dir = OUT / "iPad-12.9"
    subscription_dir = OUT / "Subscriptions"
    review_dir = OUT / "Reviews"
    square_dir = OUT / "Square-Reviews"

    screens = [
        ("01-posture-checks.png", "Posture checks for desk days", "Supportive posture cues for slouching, head tilt, leaning, and downward gaze.", make_camera(), [("possible slouch", CYAN), ("head tilt", AMBER), ("score 78", TEAL)], CYAN),
        ("02-focus-breaks.png", "Focus without forgetting breaks", "Work, study, gaming, and deep focus modes with posture and eye-rest prompts.", make_focus(), [("focus timer", BLUE), ("break cues", TEAL), ("eye rest", CYAN)], TEAL),
        ("03-desk-scan.png", "Make your workspace feel better", "Ergonomic suggestions for screen height, chair position, lighting, and keyboard reach.", make_desk(), [("monitor height", CYAN), ("soft light", BLUE), ("keyboard reach", AMBER)], AMBER),
        ("04-stretch-reset.png", "Recover with quick desk resets", "Short neck, shoulder, wrist, standing, and decompression routines.", make_stretch(), [("60 sec reset", TEAL), ("neck stretch", CYAN), ("standing reset", BLUE)], TEAL),
        ("05-insights.png", "See your desk routine improve", "Weekly trends, streaks, sitting time, break consistency, and habit milestones.", make_hero(), [("weekly trends", CYAN), ("streaks", AMBER), ("local data", TEAL)], BLUE),
        ("06-premium.png", "Upgrade for deeper insights", "Pro and Elite unlock advanced AI analysis, reports, themes, widgets, and Watch placeholders.", make_paywall(), [("Pro", CYAN), ("Elite", AMBER), ("reports", BLUE)], AMBER),
    ]

    for name, title, subtitle, art, chips, accent in screens:
        app_store_screen(IPHONE_65, iphone_dir / name, title, subtitle, art, chips, accent, "iphone")
        app_store_screen(IPAD_129, ipad_dir / name, title, subtitle, art, chips, accent, "ipad")

    subscription_screen(IPHONE_65, subscription_dir / "01-pro-monthly.png", "pro", CYAN)
    subscription_screen(IPHONE_65, subscription_dir / "02-pro-yearly.png", "pro", TEAL)
    subscription_screen(IPHONE_65, subscription_dir / "03-elite-monthly.png", "elite", AMBER)

    reviews = [
        ("01-remote-worker.png", "The posture checks make my desk breaks easier to remember.", "Remote worker", CYAN),
        ("02-student.png", "Focus mode feels calm and keeps recovery prompts in the flow.", "Student", TEAL),
        ("03-gamer.png", "A better way to notice long sitting sessions before they take over.", "Gamer", AMBER),
    ]
    for name, quote, role, accent in reviews:
        review_card(IPHONE_65, review_dir / name, quote, role, accent)
        review_card(SQUARE, square_dir / name, quote, role, accent, square=True)


def main() -> None:
    save_app_store_connect_screenshots()
    print(f"Generated App Store Connect screenshots in {OUT}")


if __name__ == "__main__":
    main()
