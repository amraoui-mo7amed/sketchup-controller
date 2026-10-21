import os
import subprocess
from PIL import Image
from PySide6.QtGui import (
    QImage, QPainter, QColor, QLinearGradient, QRadialGradient,
    QPen, QBrush, QPainterPath, QPolygonF
)
from PySide6.QtCore import QPointF, Qt

def render_master_icon(size=1024):
    img = QImage(size, size, QImage.Format_ARGB32_Premultiplied)
    img.fill(Qt.transparent)

    p = QPainter(img)
    p.setRenderHint(QPainter.Antialiasing, True)
    p.setRenderHint(QPainter.SmoothPixmapTransform, True)

    scale = size / 1024.0

    # 1. Outer Squircle Canvas
    pad = 50 * scale
    card_w = size - (2 * pad)
    card_r = 210 * scale

    squircle_path = QPainterPath()
    squircle_path.addRoundedRect(pad, pad, card_w, card_w, card_r, card_r)

    # Ambient Background Gradient
    bg_grad = QLinearGradient(0, pad, size, size - pad)
    bg_grad.setColorAt(0.0, QColor("#0D1322"))
    bg_grad.setColorAt(0.5, QColor("#070B14"))
    bg_grad.setColorAt(1.0, QColor("#030509"))
    p.fillPath(squircle_path, bg_grad)

    # Ambient Liquid Light Blobs (inside squircle mask)
    p.save()
    p.setClipPath(squircle_path)

    # Cyan Blob
    cyan_orb = QRadialGradient(320 * scale, 300 * scale, 340 * scale)
    cyan_orb.setColorAt(0.0, QColor(0, 240, 255, 90))
    cyan_orb.setColorAt(0.6, QColor(0, 240, 255, 20))
    cyan_orb.setColorAt(1.0, QColor(0, 240, 255, 0))
    p.fillRect(0, 0, size, size, cyan_orb)

    # Violet Blob
    violet_orb = QRadialGradient(720 * scale, 750 * scale, 380 * scale)
    violet_orb.setColorAt(0.0, QColor(157, 78, 221, 90))
    violet_orb.setColorAt(0.6, QColor(157, 78, 221, 20))
    violet_orb.setColorAt(1.0, QColor(157, 78, 221, 0))
    p.fillRect(0, 0, size, size, violet_orb)

    # Subtle grid lines
    grid_pen = QPen(QColor(255, 255, 255, 12))
    grid_pen.setWidthF(1.5 * scale)
    p.setPen(grid_pen)
    for x in range(150, 900, 70):
        p.drawLine(x * scale, pad, x * scale, size - pad)
    for y in range(150, 900, 70):
        p.drawLine(pad, y * scale, size - pad, y * scale)

    p.restore()

    # Specular Border on Squircle
    border_pen = QPen()
    border_grad = QLinearGradient(pad, pad, size - pad, size - pad)
    border_grad.setColorAt(0.0, QColor(0, 240, 255, 180))
    border_grad.setColorAt(0.4, QColor(255, 255, 255, 70))
    border_grad.setColorAt(0.7, QColor(157, 78, 221, 140))
    border_grad.setColorAt(1.0, QColor(0, 229, 153, 100))
    border_pen.setBrush(border_grad)
    border_pen.setWidthF(4.0 * scale)
    p.strokePath(squircle_path, border_pen)

    # 2. Isometric 3D Architectural Hologram (Center)
    cx = size / 2.0
    cy = size / 2.0 + (10 * scale)

    r_iso = 220 * scale  # radius of isometric cube
    h_iso = r_iso * 0.577 # tan(30 deg)

    # Key vertices:
    p_center = QPointF(cx, cy)
    p_top    = QPointF(cx, cy - r_iso)
    p_bot    = QPointF(cx, cy + r_iso)
    p_top_r  = QPointF(cx + r_iso * 0.866, cy - h_iso * 0.5)
    p_top_l  = QPointF(cx - r_iso * 0.866, cy - h_iso * 0.5)
    p_bot_r  = QPointF(cx + r_iso * 0.866, cy + h_iso * 0.5)
    p_bot_l  = QPointF(cx - r_iso * 0.866, cy + h_iso * 0.5)

    # Face 1: Top (Diamond)
    top_face = QPolygonF([p_top, p_top_r, p_center, p_top_l])
    top_grad = QLinearGradient(p_top_l.x(), p_top_l.y(), p_top_r.x(), p_top_r.y())
    top_grad.setColorAt(0.0, QColor(0, 240, 255, 110))
    top_grad.setColorAt(1.0, QColor(0, 229, 153, 60))
    p.setBrush(top_grad)
    p.setPen(Qt.NoPen)
    p.drawPolygon(top_face)

    # Face 2: Left
    left_face = QPolygonF([p_top_l, p_center, p_bot, p_bot_l])
    left_grad = QLinearGradient(p_top_l.x(), p_top_l.y(), p_bot.x(), p_bot.y())
    left_grad.setColorAt(0.0, QColor(157, 78, 221, 100))
    left_grad.setColorAt(1.0, QColor(50, 20, 100, 60))
    p.setBrush(left_grad)
    p.drawPolygon(left_face)

    # Face 3: Right
    right_face = QPolygonF([p_center, p_top_r, p_bot_r, p_bot])
    right_grad = QLinearGradient(p_center.x(), p_center.y(), p_bot_r.x(), p_bot_r.y())
    right_grad.setColorAt(0.0, QColor(0, 240, 255, 90))
    right_grad.setColorAt(1.0, QColor(0, 100, 180, 50))
    p.setBrush(right_grad)
    p.drawPolygon(right_face)

    # Glowing Isometric Wireframe Edges
    edge_pen = QPen(QColor(0, 240, 255, 240))
    edge_pen.setWidthF(5.0 * scale)
    edge_pen.setCapStyle(Qt.RoundCap)
    edge_pen.setJoinStyle(Qt.RoundJoin)
    p.setPen(edge_pen)
    p.setBrush(Qt.NoBrush)

    # Draw outlines
    p.drawPolygon(top_face)
    p.drawLine(p_center, p_bot)
    p.drawLine(p_top_l, p_bot_l)
    p.drawLine(p_top_r, p_bot_r)
    p.drawLine(p_bot_l, p_bot)
    p.drawLine(p_bot_r, p_bot)

    # Inner Glowing Core (Liquid Light Node)
    core_rad = 32 * scale
    core_grad = QRadialGradient(cx, cy, core_rad * 2.5)
    core_grad.setColorAt(0.0, QColor(255, 255, 255, 255))
    core_grad.setColorAt(0.25, QColor(0, 240, 255, 220))
    core_grad.setColorAt(0.6, QColor(157, 78, 221, 120))
    core_grad.setColorAt(1.0, QColor(0, 0, 0, 0))
    p.setBrush(core_grad)
    p.setPen(Qt.NoPen)
    p.drawEllipse(QPointF(cx, cy), core_rad * 2.5, core_rad * 2.5)

    # Mini architectural crosshairs / coordinates markers
    mark_pen = QPen(QColor(255, 255, 255, 180))
    mark_pen.setWidthF(2.5 * scale)
    p.setPen(mark_pen)
    for pt in [p_top, p_bot, p_top_l, p_top_r, p_bot_l, p_bot_r]:
        p.drawEllipse(pt, 5.0 * scale, 5.0 * scale)

    p.end()
    return img

def main():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    assets_dir = os.path.join(current_dir, "desktop-app", "assets")
    os.makedirs(assets_dir, exist_ok=True)

    print("Rendering 1024x1024 Master Icon...")
    master_qimg = render_master_icon(1024)
    master_png_path = os.path.join(assets_dir, "icon_1024.png")
    master_qimg.save(master_png_path)

    # Convert to PIL for multi-resolution scaling & .ico export
    pil_master = Image.open(master_png_path)

    # 1. Standard PNG exports
    app_icon_512 = pil_master.resize((512, 512), Image.Resampling.LANCZOS)
    app_icon_512.save(os.path.join(assets_dir, "app_icon.png"))

    taskbar_256 = pil_master.resize((256, 256), Image.Resampling.LANCZOS)
    taskbar_256.save(os.path.join(assets_dir, "taskbar_icon.png"))

    favicon_32 = pil_master.resize((32, 32), Image.Resampling.LANCZOS)
    favicon_32.save(os.path.join(assets_dir, "favicon.png"))

    # 2. Windows .ico containing [16, 32, 48, 64, 128, 256]
    ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    ico_imgs = [pil_master.resize(s, Image.Resampling.LANCZOS) for s in ico_sizes]
    ico_path = os.path.join(assets_dir, "icon.ico")
    ico_imgs[0].save(ico_path, format="ICO", sizes=ico_sizes, append_images=ico_imgs[1:])
    print(f"✓ Generated Windows icon: {ico_path}")

    # Favicon.ico (16, 32, 48)
    fav_ico_path = os.path.join(assets_dir, "favicon.ico")
    ico_imgs[0].save(fav_ico_path, format="ICO", sizes=[(16, 16), (32, 32), (48, 48)], append_images=ico_imgs[1:3])
    print(f"✓ Generated Favicon: {fav_ico_path}")

    # 3. macOS .icns generation via iconutil
    iconset_dir = os.path.join(assets_dir, "icon.iconset")
    os.makedirs(iconset_dir, exist_ok=True)

    sizes_map = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }

    for filename, px in sizes_map.items():
        resized = pil_master.resize((px, px), Image.Resampling.LANCZOS)
        resized.save(os.path.join(iconset_dir, filename))

    icns_path = os.path.join(assets_dir, "icon.icns")
    try:
        subprocess.run(["iconutil", "-c", "icns", iconset_dir, "-o", icns_path], check=True)
        print(f"✓ Generated macOS icon: {icns_path}")
    except Exception as e:
        print(f"iconutil warning: {e}")

    print("\nAll icon assets generated successfully!")

if __name__ == "__main__":
    main()
