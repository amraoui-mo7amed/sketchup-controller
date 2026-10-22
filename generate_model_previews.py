import os
import math
from PIL import Image, ImageDraw, ImageFont

MODELS_DIR = "/Users/amraouimohamed/sites/sketchup-controller/models"

def create_base_canvas(theme_color=(0, 245, 255)):
    # 512x512 with dark gradient background and isometric ground grid
    im = Image.new("RGB", (512, 512), (11, 15, 24))
    draw = ImageDraw.Draw(im)
    
    # Radial dark vignette
    for r in range(256, 0, -8):
        alpha = int(40 * (1 - r / 256))
        col = (
            int(11 + theme_color[0] * 0.08 * (1 - r / 256)),
            int(15 + theme_color[1] * 0.08 * (1 - r / 256)),
            int(24 + theme_color[2] * 0.08 * (1 - r / 256))
        )
        draw.ellipse([256 - r, 256 - r, 256 + r, 256 + r], fill=col)
        
    # Draw isometric ground grid lines
    cos30 = math.cos(math.radians(30))
    sin30 = math.sin(math.radians(30))
    grid_col = (25, 35, 50)
    axis_col_x = (236, 72, 153, 120)
    axis_col_y = (16, 185, 129, 120)
    
    cx, cy = 256, 360
    
    for i in range(-5, 6):
        # Lines parallel to X
        p1 = (cx + (-5 - i) * 32 * cos30, cy + (-5 + i) * 32 * sin30)
        p2 = (cx + (5 - i) * 32 * cos30, cy + (5 + i) * 32 * sin30)
        draw.line([p1, p2], fill=grid_col, width=1)
        
        # Lines parallel to Y
        p3 = (cx + (i - (-5)) * 32 * cos30, cy + (i + -5) * 32 * sin30)
        p4 = (cx + (i - 5) * 32 * cos30, cy + (i + 5) * 32 * sin30)
        draw.line([p3, p4], fill=grid_col, width=1)
        
    # Main axes
    draw.line([(cx, cy), (cx + 160 * cos30, cy + 160 * sin30)], fill=(0, 245, 255), width=2)
    draw.line([(cx, cy), (cx - 160 * cos30, cy + 160 * sin30)], fill=(16, 185, 129), width=2)
    draw.line([(cx, cy), (cx, cy - 140)], fill=(139, 92, 246), width=2)
    
    return im, draw

def pt(cx, cy, x, y, z):
    cos30 = math.cos(math.radians(30))
    sin30 = math.sin(math.radians(30))
    return (cx + (x - y) * cos30, cy + (x + y) * sin30 - z)

def draw_iso_block(draw, cx, cy, x, y, z, w, d, h, top_col, left_col, right_col, outline_col=None):
    hw, hd = w / 2, d / 2
    p0 = pt(cx, cy, x - hw, y - hd, z)
    p1 = pt(cx, cy, x + hw, y - hd, z)
    p2 = pt(cx, cy, x + hw, y + hd, z)
    p3 = pt(cx, cy, x - hw, y + hd, z)
    
    p4 = pt(cx, cy, x - hw, y - hd, z + h)
    p5 = pt(cx, cy, x + hw, y - hd, z + h)
    p6 = pt(cx, cy, x + hw, y + hd, z + h)
    p7 = pt(cx, cy, x - hw, y + hd, z + h)
    
    draw.polygon([p1, p2, p6, p5], fill=right_col)
    draw.polygon([p2, p3, p7, p6], fill=left_col)
    draw.polygon([p4, p5, p6, p7], fill=top_col)
    
    if outline_col:
        for f in [[p1, p2, p6, p5], [p2, p3, p7, p6], [p4, p5, p6, p7]]:
            draw.polygon(f, outline=outline_col, width=2)

def generate_previews():
    cx, cy = 256, 340
    
    # 1. Architectural Villa
    im, draw = create_base_canvas((0, 245, 255))
    # Base podium
    draw_iso_block(draw, cx, cy, 0, 0, 0, 220, 180, 15, (40, 50, 70), (25, 30, 45), (30, 38, 55), (0, 245, 255))
    # Ground floor glass pavilion
    draw_iso_block(draw, cx, cy, -20, -10, 15, 140, 120, 60, (20, 70, 90), (15, 45, 65), (18, 55, 75), (0, 245, 255))
    # Upper cantilevered wing
    draw_iso_block(draw, cx, cy, 20, 20, 75, 160, 100, 55, (230, 235, 245), (170, 180, 195), (195, 205, 220), (255, 255, 255))
    # Cantilever roof slab
    draw_iso_block(draw, cx, cy, 20, 20, 130, 180, 120, 12, (30, 40, 55), (15, 25, 35), (20, 30, 45), (0, 245, 255))
    # Pool feature
    draw_iso_block(draw, cx, cy, -70, 60, 5, 60, 40, 8, (0, 200, 230), (0, 140, 180), (0, 160, 200), (0, 245, 255))
    im.save(os.path.join(MODELS_DIR, "Architecture", "architectural_villa.png"))

    # 2. Arch Visualization Studio
    im, draw = create_base_canvas((139, 92, 246))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 200, 160, 12, (35, 30, 55), (20, 18, 35), (25, 22, 45), (139, 92, 246))
    draw_iso_block(draw, cx, cy, 0, 0, 12, 160, 120, 85, (50, 40, 80), (35, 28, 60), (42, 32, 70), (139, 92, 246))
    # Angled clerestory roof
    draw_iso_block(draw, cx, cy, 0, 0, 97, 180, 140, 16, (139, 92, 246), (100, 65, 180), (120, 75, 210), (255, 255, 255))
    draw_iso_block(draw, cx, cy, 30, 30, 113, 80, 60, 30, (80, 60, 130), (60, 45, 100), (70, 50, 115), (139, 92, 246))
    im.save(os.path.join(MODELS_DIR, "Architecture", "arch_visualization_studio.png"))

    # 3. Civil Engineering Pavilion
    im, draw = create_base_canvas((16, 185, 129))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 210, 210, 10, (30, 45, 40), (18, 30, 25), (22, 35, 30), (16, 185, 129))
    # 4 corner columns
    for sx in [-60, 60]:
        for sy in [-60, 60]:
            draw_iso_block(draw, cx, cy, sx, sy, 10, 20, 20, 90, (180, 200, 190), (130, 150, 140), (150, 170, 160), (16, 185, 129))
    # Canopy space truss
    draw_iso_block(draw, cx, cy, 0, 0, 100, 180, 180, 20, (16, 185, 129), (10, 130, 90), (12, 150, 105), (255, 255, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 120, 100, 100, 25, (220, 240, 230), (160, 180, 170), (180, 200, 190), (16, 185, 129))
    im.save(os.path.join(MODELS_DIR, "Architecture", "civil_engineering_pavilion.png"))

    # 4. Commercial AEC Structure
    im, draw = create_base_canvas((0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 180, 180, 15, (30, 40, 55), (18, 25, 35), (22, 30, 45), (0, 245, 255))
    # Tower levels
    draw_iso_block(draw, cx, cy, 0, 0, 15, 120, 120, 60, (40, 75, 105), (25, 55, 80), (32, 65, 92), (0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 75, 105, 105, 50, (50, 95, 130), (35, 70, 100), (42, 82, 115), (0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 125, 90, 90, 45, (65, 120, 160), (45, 90, 125), (55, 105, 142), (0, 245, 255))
    # Spire
    draw_iso_block(draw, cx, cy, 0, 0, 170, 20, 20, 45, (0, 245, 255), (0, 170, 200), (0, 200, 225), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Architecture", "commercial_aec_structure.png"))

    # 5. Metric Studio Space
    im, draw = create_base_canvas((245, 158, 11))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 190, 170, 10, (45, 40, 30), (30, 25, 18), (35, 30, 22), (245, 158, 11))
    draw_iso_block(draw, cx, cy, -20, 0, 10, 120, 140, 80, (235, 225, 210), (175, 165, 150), (195, 185, 170), (245, 158, 11))
    draw_iso_block(draw, cx, cy, 50, 0, 10, 60, 140, 50, (60, 50, 35), (42, 35, 25), (50, 42, 30), (245, 158, 11))
    # Slanted roof
    draw_iso_block(draw, cx, cy, -20, 0, 90, 140, 150, 15, (245, 158, 11), (180, 110, 10), (210, 130, 10), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Architecture", "metric_studio_space.png"))

    # 6. Minimal Studio Pod
    im, draw = create_base_canvas((236, 72, 153))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 170, 170, 12, (45, 25, 40), (30, 15, 28), (35, 18, 32), (236, 72, 153))
    draw_iso_block(draw, cx, cy, 0, 0, 12, 130, 130, 85, (240, 240, 245), (175, 175, 185), (200, 200, 210), (236, 72, 153))
    # Accent fascia
    draw_iso_block(draw, cx, cy, 0, -66, 20, 134, 4, 70, (236, 72, 153), (170, 40, 100), (200, 55, 125), (255, 255, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 97, 140, 140, 10, (40, 30, 45), (25, 18, 30), (30, 22, 35), (236, 72, 153))
    im.save(os.path.join(MODELS_DIR, "Architecture", "minimal_studio_pod.png"))

    # 7. Residential Home
    im, draw = create_base_canvas((0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 210, 190, 10, (30, 40, 50), (18, 25, 32), (22, 30, 40), (0, 245, 255))
    draw_iso_block(draw, cx, cy, -25, 0, 10, 130, 140, 75, (235, 240, 245), (175, 180, 190), (200, 205, 215), (0, 245, 255))
    draw_iso_block(draw, cx, cy, 45, 10, 10, 70, 100, 55, (50, 65, 85), (35, 45, 60), (42, 55, 72), (0, 245, 255))
    # Pitched roof
    draw_iso_block(draw, cx, cy, -25, 0, 85, 145, 155, 25, (0, 245, 255), (0, 170, 200), (0, 200, 225), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Architecture", "residential_home.png"))

    # 8. Executive Interior Office
    im, draw = create_base_canvas((245, 158, 11))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 200, 180, 10, (40, 35, 25), (25, 22, 15), (30, 26, 18), (245, 158, 11))
    # Desk top
    draw_iso_block(draw, cx, cy, 0, 0, 50, 140, 75, 12, (180, 115, 60), (120, 75, 35), (145, 90, 45), (245, 158, 11))
    # Desk legs
    draw_iso_block(draw, cx, cy, -55, 0, 10, 12, 65, 40, (40, 40, 45), (25, 25, 30), (30, 30, 35))
    draw_iso_block(draw, cx, cy, 55, 0, 10, 12, 65, 40, (40, 40, 45), (25, 25, 30), (30, 30, 35))
    # Chair
    draw_iso_block(draw, cx, cy, 0, 55, 30, 45, 45, 10, (30, 30, 35), (20, 20, 25), (25, 25, 30), (245, 158, 11))
    draw_iso_block(draw, cx, cy, 0, 72, 40, 45, 10, 50, (30, 30, 35), (20, 20, 25), (25, 25, 30))
    im.save(os.path.join(MODELS_DIR, "Furniture", "executive_interior_office.png"))

    # 9. Interior Living Suite
    im, draw = create_base_canvas((139, 92, 246))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 210, 180, 8, (35, 30, 50), (22, 18, 32), (28, 22, 40), (139, 92, 246))
    # Sectional sofa
    draw_iso_block(draw, cx, cy, -10, -10, 8, 140, 70, 30, (80, 70, 115), (55, 48, 85), (65, 58, 98), (139, 92, 246))
    draw_iso_block(draw, cx, cy, -10, -40, 38, 140, 20, 35, (95, 82, 135), (65, 55, 100), (78, 68, 115), (255, 255, 255))
    # Chaise return
    draw_iso_block(draw, cx, cy, -55, 35, 8, 50, 70, 30, (80, 70, 115), (55, 48, 85), (65, 58, 98), (139, 92, 246))
    # Coffee table
    draw_iso_block(draw, cx, cy, 35, 25, 8, 65, 45, 16, (139, 92, 246), (95, 60, 175), (115, 75, 205), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Furniture", "interior_living_suite.png"))

    # 10. Joinery Woodcraft Station
    im, draw = create_base_canvas((245, 158, 11))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 200, 170, 10, (40, 35, 25), (25, 20, 15), (30, 25, 18), (245, 158, 11))
    draw_iso_block(draw, cx, cy, 0, 0, 10, 150, 70, 45, (130, 85, 45), (85, 55, 28), (105, 68, 35), (245, 158, 11))
    draw_iso_block(draw, cx, cy, 0, 0, 55, 160, 80, 16, (215, 150, 85), (145, 100, 55), (175, 120, 68), (255, 255, 255))
    # Vise & back tool board
    draw_iso_block(draw, cx, cy, 0, -38, 71, 150, 6, 70, (100, 70, 40), (70, 48, 25), (85, 58, 32), (245, 158, 11))
    im.save(os.path.join(MODELS_DIR, "Furniture", "joinery_woodcraft_station.png"))

    # 11. Woodworking Workbench
    im, draw = create_base_canvas((16, 185, 129))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 190, 170, 10, (30, 40, 35), (18, 28, 22), (22, 32, 28), (16, 185, 129))
    draw_iso_block(draw, cx, cy, 0, 0, 10, 140, 65, 40, (50, 60, 55), (32, 40, 36), (40, 48, 44), (16, 185, 129))
    draw_iso_block(draw, cx, cy, 0, 0, 50, 155, 75, 20, (200, 140, 75), (135, 90, 48), (165, 110, 60), (255, 255, 255))
    draw_iso_block(draw, cx, cy, 65, 15, 50, 20, 20, 25, (16, 185, 129), (10, 130, 90), (12, 150, 105))
    im.save(os.path.join(MODELS_DIR, "Furniture", "woodworking_workbench.png"))

    # 12. Botanical Park Environment
    im, draw = create_base_canvas((16, 185, 129))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 220, 200, 10, (25, 45, 30), (15, 30, 20), (18, 35, 24), (16, 185, 129))
    # Pavers pathway
    draw_iso_block(draw, cx, cy, 0, 0, 10, 60, 200, 4, (120, 130, 135), (80, 88, 92), (95, 105, 110))
    # Planters & tree foliage
    draw_iso_block(draw, cx, cy, -70, -30, 10, 55, 55, 30, (60, 70, 75), (40, 48, 52), (48, 56, 60), (16, 185, 129))
    draw_iso_block(draw, cx, cy, -70, -30, 40, 45, 45, 55, (16, 185, 129), (10, 130, 90), (12, 150, 105), (255, 255, 255))
    draw_iso_block(draw, cx, cy, 70, 40, 10, 50, 50, 25, (60, 70, 75), (40, 48, 52), (48, 56, 60))
    draw_iso_block(draw, cx, cy, 70, 40, 35, 40, 40, 45, (34, 197, 94), (22, 140, 65), (26, 160, 75))
    im.save(os.path.join(MODELS_DIR, "Landscape", "botanical_park_environment.png"))

    # 13. Landscape Garden Bench
    im, draw = create_base_canvas((0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 200, 170, 10, (30, 40, 45), (18, 25, 30), (22, 30, 35), (0, 245, 255))
    # Stone plinths
    draw_iso_block(draw, cx, cy, -50, 0, 10, 25, 55, 35, (140, 145, 155), (95, 100, 110), (110, 115, 125))
    draw_iso_block(draw, cx, cy, 50, 0, 10, 25, 55, 35, (140, 145, 155), (95, 100, 110), (110, 115, 125))
    # Hardwood seat slats
    draw_iso_block(draw, cx, cy, 0, 0, 45, 145, 60, 12, (215, 140, 70), (145, 90, 45), (175, 110, 55), (0, 245, 255))
    # Bench backrest
    draw_iso_block(draw, cx, cy, 0, -25, 57, 145, 10, 45, (215, 140, 70), (145, 90, 45), (175, 110, 55), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Landscape", "landscape_garden_bench.png"))

    # 14. Metropolitan Streetscape
    im, draw = create_base_canvas((0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 220, 200, 10, (35, 40, 48), (20, 24, 30), (25, 30, 38))
    # Sidewalk curb
    draw_iso_block(draw, cx, cy, -30, 0, 10, 140, 200, 12, (100, 110, 120), (68, 75, 82), (80, 90, 98), (0, 245, 255))
    # Tree grate & foliage
    draw_iso_block(draw, cx, cy, -60, -30, 22, 40, 40, 6, (40, 45, 50), (25, 30, 35), (30, 35, 40))
    draw_iso_block(draw, cx, cy, -60, -30, 28, 10, 10, 80, (90, 65, 45), (60, 42, 28), (72, 50, 35))
    draw_iso_block(draw, cx, cy, -60, -30, 108, 60, 60, 55, (16, 185, 129), (10, 130, 90), (12, 150, 105), (255, 255, 255))
    # Street lamp
    draw_iso_block(draw, cx, cy, -10, 50, 22, 8, 8, 120, (180, 190, 200), (120, 130, 140), (140, 150, 160), (0, 245, 255))
    im.save(os.path.join(MODELS_DIR, "Landscape", "metropolitan_streetscape.png"))

    # 15. Urban Plaza District
    im, draw = create_base_canvas((139, 92, 246))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 220, 200, 12, (40, 35, 55), (25, 20, 35), (30, 25, 42), (139, 92, 246))
    draw_iso_block(draw, cx, cy, 0, 0, 12, 160, 150, 14, (120, 115, 140), (80, 75, 95), (95, 90, 112))
    draw_iso_block(draw, cx, cy, 0, 0, 26, 100, 100, 14, (150, 145, 175), (100, 95, 120), (120, 115, 142))
    # Water sculpture
    draw_iso_block(draw, cx, cy, 0, 0, 40, 50, 50, 45, (0, 245, 255), (0, 170, 200), (0, 200, 225), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Landscape", "urban_plaza_district.png"))

    # 16. Chamfer Column Pedestal
    im, draw = create_base_canvas((245, 158, 11))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 180, 180, 12, (45, 38, 30), (28, 22, 18), (32, 28, 22), (245, 158, 11))
    # Plinth base
    draw_iso_block(draw, cx, cy, 0, 0, 12, 120, 120, 30, (225, 215, 195), (160, 150, 135), (185, 175, 160), (245, 158, 11))
    # Column shaft
    draw_iso_block(draw, cx, cy, 0, 0, 42, 70, 70, 110, (240, 235, 220), (175, 170, 155), (200, 195, 180), (245, 158, 11))
    # Capital
    draw_iso_block(draw, cx, cy, 0, 0, 152, 110, 110, 25, (245, 158, 11), (180, 110, 10), (210, 130, 10), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Structural", "chamfer_column_pedestal.png"))

    # 17. Fillet Molding Profile
    im, draw = create_base_canvas((139, 92, 246))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 180, 180, 10, (35, 30, 50), (22, 18, 32), (28, 22, 40), (139, 92, 246))
    # Tiered molding profiles
    draw_iso_block(draw, cx, cy, 0, 0, 10, 140, 90, 25, (160, 145, 190), (110, 95, 135), (130, 115, 155), (139, 92, 246))
    draw_iso_block(draw, cx, cy, 0, 0, 35, 120, 80, 35, (190, 175, 225), (130, 115, 160), (155, 140, 185), (255, 255, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 70, 95, 70, 45, (139, 92, 246), (95, 60, 175), (115, 75, 205), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Structural", "fillet_molding_profile.png"))

    # 18. Precision Fabrication Bed
    im, draw = create_base_canvas((0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 200, 180, 15, (30, 35, 45), (18, 22, 30), (22, 28, 36), (0, 245, 255))
    # Heated bed matrix
    draw_iso_block(draw, cx, cy, 0, 0, 15, 150, 140, 15, (25, 110, 130), (15, 80, 95), (18, 95, 112), (0, 245, 255))
    # Gantry uprights
    draw_iso_block(draw, cx, cy, -70, 0, 30, 16, 24, 110, (180, 190, 200), (120, 130, 140), (140, 150, 160))
    draw_iso_block(draw, cx, cy, 70, 0, 30, 16, 24, 110, (180, 190, 200), (120, 130, 140), (140, 150, 160))
    # Cross beam gantry
    draw_iso_block(draw, cx, cy, 0, 0, 130, 165, 20, 20, (0, 245, 255), (0, 170, 200), (0, 200, 225), (255, 255, 255))
    # Toolhead
    draw_iso_block(draw, cx, cy, 0, 0, 95, 30, 30, 35, (236, 72, 153), (170, 40, 100), (200, 55, 125))
    im.save(os.path.join(MODELS_DIR, "Structural", "precision_fabrication_bed.png"))

    # 19. Prototyping 3D Base
    im, draw = create_base_canvas((0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 0, 210, 190, 18, (35, 45, 55), (20, 28, 35), (25, 35, 45), (0, 245, 255))
    draw_iso_block(draw, cx, cy, 0, 0, 18, 170, 150, 12, (50, 70, 90), (32, 48, 65), (40, 58, 76), (0, 245, 255))
    # Fixture blocks
    for bx, by in [(-50, -40), (50, -40), (-50, 40), (50, 40)]:
        draw_iso_block(draw, cx, cy, bx, by, 30, 25, 25, 45, (16, 185, 129), (10, 130, 90), (12, 150, 105))
    # Central test part
    draw_iso_block(draw, cx, cy, 0, 0, 30, 60, 60, 60, (0, 245, 255), (0, 170, 200), (0, 200, 225), (255, 255, 255))
    im.save(os.path.join(MODELS_DIR, "Structural", "prototyping_3d_base.png"))

    print("Successfully generated 19 rich 3D model preview renderings in models/!")

if __name__ == "__main__":
    generate_previews()
