"""
SketchUp MCP Server (Model Context Protocol)
Connects AI agents (Claude Desktop, Cursor, Antigravity) to SketchUp 2026
via the local HTTP Bridge (http://127.0.0.1:9876).
"""

import json
import httpx
from mcp.server.mcpserver import MCPServer

BRIDGE_URL = "http://127.0.0.1:9876"

mcp = MCPServer("sketchup-controller")

def _call_bridge(endpoint: str, payload: dict | None = None) -> dict:
    try:
        with httpx.Client(timeout=10.0) as client:
            if payload is None:
                res = client.get(f"{BRIDGE_URL}{endpoint}")
            else:
                res = client.post(f"{BRIDGE_URL}{endpoint}", json=payload)
            return res.json()
    except httpx.ConnectError:
        return {
            "status": "error",
            "message": "SketchUp Bridge is OFFLINE. Ensure SketchUp 2026 is open with the SketchUp Controller plugin."
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@mcp.tool()
def sketchup_get_status() -> str:
    """
    Get active SketchUp status, model title, units, entity count, and bounding box dimensions.
    """
    data = _call_bridge("/api/status")
    return json.dumps(data, indent=2)

@mcp.tool()
def sketchup_create_room(
    width: float = 6.0,
    depth: float = 5.0,
    height: float = 3.0,
    wall_thickness: float = 0.20
) -> str:
    """
    Generate a 3D architectural room in SketchUp with exact dimensions in meters.
    Includes extruded perimeter walls, floor slab, and centered door opening.
    """
    data = _call_bridge("/api/design/room", {
        "width": width,
        "depth": depth,
        "height": height,
        "wall_thickness": wall_thickness,
        "has_floor": True
    })
    return json.dumps(data, indent=2)

@mcp.tool()
def sketchup_create_box(
    width: float = 4.0,
    depth: float = 4.0,
    height: float = 3.0
) -> str:
    """
    Generate a solid 3D box or massing volume in SketchUp with dimensions in meters.
    """
    data = _call_bridge("/api/design/box", {
        "width": width,
        "depth": depth,
        "height": height
    })
    return json.dumps(data, indent=2)

@mcp.tool()
def sketchup_create_cylinder(
    radius: float = 1.0,
    height: float = 4.0,
    segments: int = 24
) -> str:
    """
    Generate a cylindrical architectural column or circular tower in SketchUp.
    """
    data = _call_bridge("/api/design/cylinder", {
        "radius": radius,
        "height": height,
        "segments": segments
    })
    return json.dumps(data, indent=2)

@mcp.tool()
def sketchup_set_camera(view: str = "iso") -> str:
    """
    Orient the SketchUp viewport camera and fit scene extents.
    Allowed values for view: 'iso' (Isometric 3D), 'top' (Plan), 'front', 'right', 'left'.
    """
    data = _call_bridge("/api/camera", {"view": view})
    return json.dumps(data, indent=2)

@mcp.tool()
def sketchup_export_model(format: str = "obj", file_path: str = "") -> str:
    """
    Export the active SketchUp model to disk.
    Supported formats: 'obj', 'stl', 'dae', 'dwg', 'png' (viewport render).
    If file_path is empty, automatically saves to ~/Desktop with a timestamp.
    """
    payload = {"format": format}
    if file_path:
        payload["path"] = file_path
    data = _call_bridge("/api/export", payload)
    return json.dumps(data, indent=2)

@mcp.tool()
def sketchup_clear_model() -> str:
    """
    Clear all active entities in the SketchUp viewport.
    """
    data = _call_bridge("/api/design/clear", {})
    return json.dumps(data, indent=2)

@mcp.tool()
def sketchup_eval_ruby(ruby_code: str) -> str:
    """
    Execute raw procedural Ruby code directly inside SketchUp's Ruby API engine.
    Runs inside a transaction with undo stack support.
    """
    data = _call_bridge("/api/eval", {"code": ruby_code})
    return json.dumps(data, indent=2)

@mcp.resource("sketchup://active_model/summary")
def get_model_summary() -> str:
    """
    Get a formatted Markdown summary of the currently loaded SketchUp model.
    """
    data = _call_bridge("/api/status")
    if data.get("status") != "online":
        return "# SketchUp Status\n\nBridge is currently offline. Open SketchUp 2026."

    counts = data.get("counts", {})
    bounds = data.get("bounds", {})
    return f"""# SketchUp Model: {data.get('model_name')}
- **SketchUp Version:** {data.get('app_version')}
- **Units:** {data.get('units')}
- **Dimensions:** {bounds.get('width_m')}m (W) × {bounds.get('depth_m')}m (D) × {bounds.get('height_m')}m (H)
- **Faces:** {counts.get('faces')}
- **Edges:** {counts.get('edges')}
- **Groups:** {counts.get('groups')}
- **Components:** {counts.get('components')}
- **Scenes:** {counts.get('scenes')}
"""

if __name__ == "__main__":
    mcp.run()
