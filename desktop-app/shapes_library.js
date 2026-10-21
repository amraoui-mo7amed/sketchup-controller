.pragma library

var categories = [
  {
    "id": "all",
    "name": "All 150 Shapes",
    "icon": "\uf5aa"
  },
  {
    "id": "architecture",
    "name": "Architecture",
    "icon": "\uf015"
  },
  {
    "id": "stairs",
    "name": "Circulation & Stairs",
    "icon": "\uf550"
  },
  {
    "id": "columns",
    "name": "Columns & Pillars",
    "icon": "\uf1ad"
  },
  {
    "id": "structural",
    "name": "Structural Steel",
    "icon": "\uf547"
  },
  {
    "id": "roofs",
    "name": "Roofs & Trusses",
    "icon": "\uf015"
  },
  {
    "id": "primitives",
    "name": "3D Primitives",
    "icon": "\uf1b2"
  },
  {
    "id": "furniture",
    "name": "Interior Furniture",
    "icon": "\uf468"
  },
  {
    "id": "landscape",
    "name": "Landscape & Urban",
    "icon": "\uf1b3"
  }
];

var allShapes = [
  {
    "id": "room_std",
    "name": "Parametric Room",
    "category": "architecture",
    "icon": "\uf015",
    "desc": "Full enclosed room with floor slab and 4 walls",
    "params": [
      {
        "key": "width",
        "name": "Width (X)",
        "val": 6.0,
        "min": 2.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth (Y)",
        "val": 5.0,
        "min": 2.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height (Z)",
        "val": 3.0,
        "min": 2.0,
        "max": 10.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Wall Thickness",
        "val": 0.2,
        "min": 0.1,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "wall_straight",
    "name": "Straight Partition Wall",
    "category": "architecture",
    "icon": "\uf545",
    "desc": "Single straight interior partition wall",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 4.0,
        "min": 1.0,
        "max": 20.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 2.8,
        "min": 1.5,
        "max": 6.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Thickness",
        "val": 0.15,
        "min": 0.08,
        "max": 0.4,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "wall_curved",
    "name": "Curved Radius Wall",
    "category": "architecture",
    "icon": "\uf5ee",
    "desc": "Sweeping curved circular wall arc",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 4.0,
        "min": 1.5,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.0,
        "min": 1.5,
        "max": 6.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "angle",
        "name": "Arc Angle",
        "val": 90.0,
        "min": 30.0,
        "max": 180.0,
        "step": 15.0,
        "unit": "\u00b0"
      },
      {
        "key": "thick",
        "name": "Thickness",
        "val": 0.2,
        "min": 0.1,
        "max": 0.5,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "wall_door",
    "name": "Wall with Door Opening",
    "category": "architecture",
    "icon": "\uf015",
    "desc": "Wall panel with framed doorway cutout",
    "params": [
      {
        "key": "length",
        "name": "Wall Length",
        "val": 4.0,
        "min": 2.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Wall Height",
        "val": 2.8,
        "min": 2.2,
        "max": 5.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "door_w",
        "name": "Door Width",
        "val": 0.9,
        "min": 0.7,
        "max": 1.8,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "door_h",
        "name": "Door Height",
        "val": 2.1,
        "min": 1.9,
        "max": 2.5,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "wall_window",
    "name": "Wall with Window Opening",
    "category": "architecture",
    "icon": "\uf015",
    "desc": "Wall with framed rectangular window opening",
    "params": [
      {
        "key": "length",
        "name": "Wall Length",
        "val": 4.0,
        "min": 2.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Wall Height",
        "val": 2.8,
        "min": 2.2,
        "max": 5.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "win_w",
        "name": "Window Width",
        "val": 1.4,
        "min": 0.6,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "win_h",
        "name": "Window Height",
        "val": 1.2,
        "min": 0.6,
        "max": 2.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "arch_roman",
    "name": "Roman Semicircular Arch",
    "category": "architecture",
    "icon": "\uf1ad",
    "desc": "Classic round arch opening",
    "params": [
      {
        "key": "span",
        "name": "Span Width",
        "val": 2.4,
        "min": 1.0,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Springing Height",
        "val": 2.0,
        "min": 1.0,
        "max": 5.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Arch Depth",
        "val": 0.4,
        "min": 0.2,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "arch_gothic",
    "name": "Gothic Pointed Arch",
    "category": "architecture",
    "icon": "\uf1ad",
    "desc": "Pointed ogival Gothic cathedral arch",
    "params": [
      {
        "key": "span",
        "name": "Span Width",
        "val": 2.4,
        "min": 1.0,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Total Height",
        "val": 3.5,
        "min": 2.0,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Arch Depth",
        "val": 0.4,
        "min": 0.2,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "vault_barrel",
    "name": "Barrel Vault Tunnel",
    "category": "architecture",
    "icon": "\uf5ee",
    "desc": "Continuous semicircular arched vault ceiling",
    "params": [
      {
        "key": "span",
        "name": "Vault Span",
        "val": 4.0,
        "min": 2.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Tunnel Length",
        "val": 8.0,
        "min": 2.0,
        "max": 30.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Vault Shell Thick",
        "val": 0.25,
        "min": 0.1,
        "max": 0.6,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "vault_groin",
    "name": "Groin Cross Vault",
    "category": "architecture",
    "icon": "\uf5ee",
    "desc": "Intersection of two perpendicular barrel vaults",
    "params": [
      {
        "key": "span",
        "name": "Square Bay Span",
        "val": 5.0,
        "min": 2.5,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Peak Height",
        "val": 3.5,
        "min": 2.0,
        "max": 7.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Shell Thickness",
        "val": 0.2,
        "min": 0.1,
        "max": 0.5,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "balcony_cantilever",
    "name": "Cantilevered Balcony",
    "category": "architecture",
    "icon": "\uf015",
    "desc": "Projecting slab with glass or metal guardrail",
    "params": [
      {
        "key": "width",
        "name": "Balcony Width",
        "val": 3.5,
        "min": 1.5,
        "max": 10.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "projection",
        "name": "Projection",
        "val": 1.5,
        "min": 0.8,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "rail_h",
        "name": "Railing Height",
        "val": 1.05,
        "min": 0.9,
        "max": 1.3,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "parapet_wall",
    "name": "Parapet Roof Edge Wall",
    "category": "architecture",
    "icon": "\uf545",
    "desc": "Low perimeter safety wall around flat roof",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 8.0,
        "min": 2.0,
        "max": 30.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 1.1,
        "min": 0.6,
        "max": 1.8,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Thickness",
        "val": 0.25,
        "min": 0.15,
        "max": 0.45,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "skylight_well",
    "name": "Rectangular Skylight Lightwell",
    "category": "architecture",
    "icon": "\uf1b2",
    "desc": "Angled lightwell opening through roof slab",
    "params": [
      {
        "key": "width",
        "name": "Opening Width",
        "val": 1.8,
        "min": 0.8,
        "max": 4.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Opening Length",
        "val": 2.4,
        "min": 0.8,
        "max": 6.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Shaft Depth",
        "val": 1.2,
        "min": 0.4,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "light_shaft",
    "name": "Vertical Atrium Light Shaft",
    "category": "architecture",
    "icon": "\uf1b2",
    "desc": "Multi-floor vertical core light well",
    "params": [
      {
        "key": "size",
        "name": "Core Size",
        "val": 3.0,
        "min": 1.5,
        "max": 8.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Total Height",
        "val": 9.0,
        "min": 3.0,
        "max": 30.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "wall_t",
        "name": "Wall Thickness",
        "val": 0.25,
        "min": 0.15,
        "max": 0.5,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "elevator_core",
    "name": "Reinforced Concrete Elevator Core",
    "category": "architecture",
    "icon": "\uf1ad",
    "desc": "Structural shear core with door openings",
    "params": [
      {
        "key": "width",
        "name": "Core Width",
        "val": 2.6,
        "min": 1.8,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Core Depth",
        "val": 2.4,
        "min": 1.8,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Floor Height",
        "val": 3.5,
        "min": 2.8,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stairwell_box",
    "name": "Enclosed Fire Stairwell Core",
    "category": "architecture",
    "icon": "\uf550",
    "desc": "Fire-rated stair enclosure shaft",
    "params": [
      {
        "key": "width",
        "name": "Stairwell Width",
        "val": 2.8,
        "min": 2.2,
        "max": 5.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Stairwell Length",
        "val": 5.2,
        "min": 4.0,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Story Height",
        "val": 3.2,
        "min": 2.8,
        "max": 12.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "curtain_wall",
    "name": "Mullion Glass Curtain Wall Panel",
    "category": "architecture",
    "icon": "\uf1ad",
    "desc": "Glazed fa\u00e7ade panel with structural mullions",
    "params": [
      {
        "key": "width",
        "name": "Bay Width",
        "val": 4.0,
        "min": 1.5,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Floor-to-Floor",
        "val": 3.6,
        "min": 2.5,
        "max": 6.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "grid_x",
        "name": "Mullion Spacing",
        "val": 1.0,
        "min": 0.6,
        "max": 2.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "louver_screen",
    "name": "Parametric Sunshade Louver Screen",
    "category": "architecture",
    "icon": "\uf545",
    "desc": "Array of angled solar shading slats",
    "params": [
      {
        "key": "width",
        "name": "Screen Width",
        "val": 3.0,
        "min": 1.0,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Screen Height",
        "val": 2.4,
        "min": 1.0,
        "max": 5.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "slat_count",
        "name": "Slat Count",
        "val": 12,
        "min": 4,
        "max": 30,
        "step": 1,
        "unit": "slats"
      },
      {
        "key": "angle",
        "name": "Blade Tilt",
        "val": 35.0,
        "min": 0.0,
        "max": 75.0,
        "step": 5.0,
        "unit": "\u00b0"
      }
    ],
    "quick": false
  },
  {
    "id": "brise_soleil",
    "name": "Concrete Brise-Soleil Eggcrate",
    "category": "architecture",
    "icon": "\uf1ad",
    "desc": "Deep architectural concrete shadow box grid",
    "params": [
      {
        "key": "width",
        "name": "Width",
        "val": 4.0,
        "min": 2.0,
        "max": 10.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.0,
        "min": 1.5,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Fin Projection Depth",
        "val": 0.6,
        "min": 0.3,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "canopy_entrance",
    "name": "Cantilevered Entrance Canopy",
    "category": "architecture",
    "icon": "\uf015",
    "desc": "Modern suspended building entrance overhang",
    "params": [
      {
        "key": "width",
        "name": "Canopy Width",
        "val": 3.6,
        "min": 1.8,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "projection",
        "name": "Overhang Depth",
        "val": 2.2,
        "min": 1.0,
        "max": 4.5,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Fascia Thickness",
        "val": 0.2,
        "min": 0.1,
        "max": 0.4,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "portico_classic",
    "name": "Classical Colonnaded Portico",
    "category": "architecture",
    "icon": "\uf1ad",
    "desc": "Entrance porch with entablature and pediment",
    "params": [
      {
        "key": "width",
        "name": "Portico Width",
        "val": 5.0,
        "min": 3.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Porch Depth",
        "val": 2.4,
        "min": 1.5,
        "max": 5.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Column Height",
        "val": 3.8,
        "min": 2.5,
        "max": 7.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "terrace_slab",
    "name": "Elevated Terrace Deck Slab",
    "category": "architecture",
    "icon": "\uf1b2",
    "desc": "Horizontal reinforced floor or roof terrace slab",
    "params": [
      {
        "key": "width",
        "name": "Width (X)",
        "val": 8.0,
        "min": 2.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length (Y)",
        "val": 6.0,
        "min": 2.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Slab Thickness",
        "val": 0.25,
        "min": 0.15,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "corridor_hall",
    "name": "Architectural Corridor Hallway",
    "category": "architecture",
    "icon": "\uf015",
    "desc": "Straight circulation corridor with end doorways",
    "params": [
      {
        "key": "width",
        "name": "Clear Width",
        "val": 1.8,
        "min": 1.2,
        "max": 3.6,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Hall Length",
        "val": 12.0,
        "min": 3.0,
        "max": 40.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Ceiling Height",
        "val": 2.8,
        "min": 2.2,
        "max": 4.5,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "mezzanine_deck",
    "name": "Steel-Framed Mezzanine Platform",
    "category": "architecture",
    "icon": "\uf1ad",
    "desc": "Intermediate open platform with posts & railing",
    "params": [
      {
        "key": "width",
        "name": "Platform Width",
        "val": 5.0,
        "min": 2.5,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Platform Depth",
        "val": 4.0,
        "min": 2.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "clear_h",
        "name": "Underside Clearance",
        "val": 2.5,
        "min": 2.1,
        "max": 4.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "foundation_footing",
    "name": "Isolated Spread Footing & Pier",
    "category": "architecture",
    "icon": "\uf1b2",
    "desc": "Concrete foundation pad with square column base",
    "params": [
      {
        "key": "pad_w",
        "name": "Pad Width",
        "val": 1.8,
        "min": 0.8,
        "max": 4.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "pad_t",
        "name": "Pad Thickness",
        "val": 0.45,
        "min": 0.25,
        "max": 1.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "pier_h",
        "name": "Pier Stem Height",
        "val": 0.9,
        "min": 0.4,
        "max": 2.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "retaining_wall_arch",
    "name": "Cantilevered Concrete Retaining Wall",
    "category": "architecture",
    "icon": "\uf545",
    "desc": "T-shaped earth retention wall with footing heel & toe",
    "params": [
      {
        "key": "stem_h",
        "name": "Wall Height",
        "val": 3.0,
        "min": 1.5,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Wall Length",
        "val": 6.0,
        "min": 2.0,
        "max": 20.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "base_w",
        "name": "Footing Width",
        "val": 1.8,
        "min": 0.9,
        "max": 3.5,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_straight",
    "name": "Straight Monolithic Stairs",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Solid continuous concrete straight staircase",
    "params": [
      {
        "key": "steps",
        "name": "Steps Count",
        "val": 15,
        "min": 3,
        "max": 35,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "width",
        "name": "Stair Width",
        "val": 1.0,
        "min": 0.6,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "tread",
        "name": "Tread Depth",
        "val": 0.28,
        "min": 0.2,
        "max": 0.4,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "riser",
        "name": "Riser Height",
        "val": 0.18,
        "min": 0.14,
        "max": 0.22,
        "step": 0.005,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "stair_floating",
    "name": "Open-Riser Floating Stairs",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Modern cantilevered floating timber/steel treads",
    "params": [
      {
        "key": "steps",
        "name": "Steps Count",
        "val": 14,
        "min": 3,
        "max": 30,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "width",
        "name": "Stair Width",
        "val": 1.1,
        "min": 0.8,
        "max": 2.5,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "tread",
        "name": "Tread Depth",
        "val": 0.29,
        "min": 0.22,
        "max": 0.38,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "riser",
        "name": "Riser Height",
        "val": 0.175,
        "min": 0.14,
        "max": 0.22,
        "step": 0.005,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "stair_spiral",
    "name": "Spiral Helical Stairs",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Helical winding staircase around central pillar",
    "params": [
      {
        "key": "steps",
        "name": "Steps Count",
        "val": 18,
        "min": 8,
        "max": 36,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "radius",
        "name": "Outer Radius",
        "val": 1.25,
        "min": 0.8,
        "max": 2.5,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "riser",
        "name": "Step Rise",
        "val": 0.18,
        "min": 0.14,
        "max": 0.22,
        "step": 0.005,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "stair_l_shape",
    "name": "L-Shaped Stair with Landing",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Quarter-turn 90-degree staircase with rest landing",
    "params": [
      {
        "key": "flight1",
        "name": "Lower Flight Steps",
        "val": 8,
        "min": 3,
        "max": 18,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "flight2",
        "name": "Upper Flight Steps",
        "val": 8,
        "min": 3,
        "max": 18,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "width",
        "name": "Stair Width",
        "val": 1.0,
        "min": 0.8,
        "max": 2.2,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_u_shape",
    "name": "U-Shaped Switchback Stairs",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Half-turn 180-degree double flight staircase with landing",
    "params": [
      {
        "key": "flight",
        "name": "Steps Per Flight",
        "val": 8,
        "min": 4,
        "max": 16,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "width",
        "name": "Stair Width",
        "val": 1.1,
        "min": 0.8,
        "max": 2.2,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "riser",
        "name": "Riser Height",
        "val": 0.175,
        "min": 0.14,
        "max": 0.21,
        "step": 0.005,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_winder",
    "name": "Curved Winder Staircase",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Continuous flowing curved steps without flat landing",
    "params": [
      {
        "key": "steps",
        "name": "Total Steps",
        "val": 16,
        "min": 8,
        "max": 28,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "width",
        "name": "Stair Width",
        "val": 1.1,
        "min": 0.8,
        "max": 2.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "radius",
        "name": "Inner Curve Radius",
        "val": 1.5,
        "min": 0.8,
        "max": 4.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_cantilever",
    "name": "Single-Stringer Cantilever Steps",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Center spine mono-stringer staircase with timber treads",
    "params": [
      {
        "key": "steps",
        "name": "Steps Count",
        "val": 14,
        "min": 4,
        "max": 24,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "width",
        "name": "Stair Width",
        "val": 1.0,
        "min": 0.8,
        "max": 2.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "spine_w",
        "name": "Steel Spine Width",
        "val": 0.2,
        "min": 0.1,
        "max": 0.4,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_dog_leg",
    "name": "Concrete Dog-Leg Stairs",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Commercial monolithic two-flight concrete stairs",
    "params": [
      {
        "key": "steps_flight",
        "name": "Steps per Flight",
        "val": 10,
        "min": 4,
        "max": 16,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "width",
        "name": "Width",
        "val": 1.2,
        "min": 0.9,
        "max": 2.4,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "landing_d",
        "name": "Landing Depth",
        "val": 1.3,
        "min": 1.0,
        "max": 2.5,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_scaffold",
    "name": "Industrial Scaffolding Stair Tower",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Modular steel scaffolding stair unit with landings",
    "params": [
      {
        "key": "bay_w",
        "name": "Tower Width",
        "val": 2.5,
        "min": 1.8,
        "max": 4.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "bay_d",
        "name": "Tower Depth",
        "val": 2.5,
        "min": 1.8,
        "max": 4.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Lift Height",
        "val": 3.0,
        "min": 2.0,
        "max": 6.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_fire_escape",
    "name": "Exterior Steel Fire Escape",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Open metal mesh egress stair with safety balustrades",
    "params": [
      {
        "key": "steps",
        "name": "Steps Count",
        "val": 16,
        "min": 6,
        "max": 24,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "width",
        "name": "Tread Width",
        "val": 0.9,
        "min": 0.75,
        "max": 1.5,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "rail_h",
        "name": "Railing Height",
        "val": 1.1,
        "min": 0.95,
        "max": 1.3,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_ramp_ada",
    "name": "Accessible Wheelchair Ramp (ADA)",
    "category": "stairs",
    "icon": "\uf5ee",
    "desc": "Code-compliant 1:12 slope ramp with landing",
    "params": [
      {
        "key": "run_l",
        "name": "Ramp Run Length",
        "val": 6.0,
        "min": 2.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Clear Width",
        "val": 1.2,
        "min": 1.0,
        "max": 2.4,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "slope",
        "name": "Slope Ratio (1:X)",
        "val": 12.0,
        "min": 8.0,
        "max": 20.0,
        "step": 1.0,
        "unit": "ratio"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_imperial",
    "name": "Grand Imperial Double Staircase",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Monumental central flight splitting into two return flights",
    "params": [
      {
        "key": "central_w",
        "name": "Central Flight Width",
        "val": 2.4,
        "min": 1.8,
        "max": 5.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "side_w",
        "name": "Return Flight Width",
        "val": 1.4,
        "min": 1.0,
        "max": 2.5,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "steps",
        "name": "Flight Steps",
        "val": 10,
        "min": 5,
        "max": 18,
        "step": 1,
        "unit": "steps"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_bleachers",
    "name": "Stepped Bleachers / Amphitheater Podium",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Deep seated tier steps for public gatherings",
    "params": [
      {
        "key": "tiers",
        "name": "Number of Tiers",
        "val": 6,
        "min": 3,
        "max": 15,
        "step": 1,
        "unit": "tiers"
      },
      {
        "key": "width",
        "name": "Bleacher Width",
        "val": 8.0,
        "min": 3.0,
        "max": 25.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "bench_d",
        "name": "Bench Depth",
        "val": 0.8,
        "min": 0.6,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "riser",
        "name": "Riser Height",
        "val": 0.4,
        "min": 0.3,
        "max": 0.5,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_spiral_col",
    "name": "Spiral Staircase with Central Shaft",
    "category": "stairs",
    "icon": "\uf550",
    "desc": "Helical stair surrounded by outer glass enclosure",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 1.4,
        "min": 0.9,
        "max": 2.8,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "steps",
        "name": "Steps Count",
        "val": 18,
        "min": 10,
        "max": 32,
        "step": 1,
        "unit": "steps"
      },
      {
        "key": "riser",
        "name": "Step Rise",
        "val": 0.175,
        "min": 0.14,
        "max": 0.21,
        "step": 0.005,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "stair_arena_steps",
    "name": "Concentric Circular Arena Steps",
    "category": "stairs",
    "icon": "\uf5ee",
    "desc": "Radial tiered amphitheater seating rings",
    "params": [
      {
        "key": "tiers",
        "name": "Number of Tiers",
        "val": 5,
        "min": 3,
        "max": 12,
        "step": 1,
        "unit": "tiers"
      },
      {
        "key": "inner_r",
        "name": "Stage Center Radius",
        "val": 4.0,
        "min": 2.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "tier_w",
        "name": "Tier Depth",
        "val": 0.9,
        "min": 0.6,
        "max": 1.4,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_cylinder",
    "name": "Modern Cylindrical Column",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Smooth round structural concrete or steel column",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 0.25,
        "min": 0.1,
        "max": 1.2,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Column Height",
        "val": 3.5,
        "min": 1.5,
        "max": 12.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "col_square",
    "name": "Square Structural Pillar",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Square profile reinforced concrete or stone pillar",
    "params": [
      {
        "key": "size",
        "name": "Width / Depth",
        "val": 0.4,
        "min": 0.15,
        "max": 1.5,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Column Height",
        "val": 3.5,
        "min": 1.5,
        "max": 12.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "col_doric",
    "name": "Classical Doric Order Column",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Sturdy fluted column with simple echinus & abacus capital",
    "params": [
      {
        "key": "radius",
        "name": "Base Radius",
        "val": 0.35,
        "min": 0.2,
        "max": 1.0,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 4.2,
        "min": 2.5,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "taper",
        "name": "Entasis Taper (%)",
        "val": 15.0,
        "min": 5.0,
        "max": 25.0,
        "step": 1.0,
        "unit": "%"
      }
    ],
    "quick": true
  },
  {
    "id": "col_ionic",
    "name": "Ionic Classical Column with Volutes",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Slender fluted column with scroll-like volute capital",
    "params": [
      {
        "key": "radius",
        "name": "Base Radius",
        "val": 0.3,
        "min": 0.18,
        "max": 0.9,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 4.5,
        "min": 2.5,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_corinthian",
    "name": "Corinthian Acanthus Column",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Elaborate classical capital with acanthus leaves",
    "params": [
      {
        "key": "radius",
        "name": "Base Radius",
        "val": 0.32,
        "min": 0.18,
        "max": 0.9,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 4.8,
        "min": 2.5,
        "max": 12.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_fluted",
    "name": "Fluted Classical Pillar",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Shaft with 20 concave vertical flutes around perimeter",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 0.3,
        "min": 0.15,
        "max": 0.8,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.6,
        "min": 2.0,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "flutes",
        "name": "Flute Count",
        "val": 20,
        "min": 8,
        "max": 32,
        "step": 2,
        "unit": "grooves"
      }
    ],
    "quick": false
  },
  {
    "id": "col_tapered",
    "name": "Tapered Modern Concrete Pier",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Pyramidal truncated slender architectural column",
    "params": [
      {
        "key": "base_w",
        "name": "Base Width",
        "val": 0.6,
        "min": 0.25,
        "max": 1.5,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "top_w",
        "name": "Top Width",
        "val": 0.35,
        "min": 0.15,
        "max": 1.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.8,
        "min": 2.0,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_octagonal",
    "name": "Octagonal Stone Pillar",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "8-sided prismatic architectural column",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 0.3,
        "min": 0.15,
        "max": 1.0,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.4,
        "min": 1.8,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_cluster",
    "name": "Clustered Gothic Column Group",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Bundle of 4 engaged colonnettes supporting a pier",
    "params": [
      {
        "key": "shaft_r",
        "name": "Sub-shaft Radius",
        "val": 0.14,
        "min": 0.08,
        "max": 0.3,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "spacing",
        "name": "Cluster Radius",
        "val": 0.25,
        "min": 0.15,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 4.5,
        "min": 2.5,
        "max": 12.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_pedestal",
    "name": "Sculptural Pedestal Plinth",
    "category": "columns",
    "icon": "\uf1b2",
    "desc": "Stepped display plinth with molded base & cornice",
    "params": [
      {
        "key": "base_w",
        "name": "Base Width",
        "val": 0.8,
        "min": 0.4,
        "max": 2.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "top_w",
        "name": "Top Width",
        "val": 0.6,
        "min": 0.3,
        "max": 1.6,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Total Height",
        "val": 1.1,
        "min": 0.5,
        "max": 2.5,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_obelisk",
    "name": "Monumental Tapered Obelisk",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Four-sided monolithic pillar tapering to a pyramidion cap",
    "params": [
      {
        "key": "base_w",
        "name": "Base Width",
        "val": 1.0,
        "min": 0.4,
        "max": 3.5,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Shaft Height",
        "val": 8.0,
        "min": 3.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "pyramid_h",
        "name": "Cap Pyramid Height",
        "val": 1.2,
        "min": 0.4,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_pilaster",
    "name": "Engaged Wall Pilaster",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Shallow decorative rectangular column projecting from wall",
    "params": [
      {
        "key": "width",
        "name": "Face Width",
        "val": 0.4,
        "min": 0.2,
        "max": 1.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "projection",
        "name": "Wall Projection",
        "val": 0.12,
        "min": 0.05,
        "max": 0.35,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.2,
        "min": 1.8,
        "max": 7.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_solomonic",
    "name": "Twisted Solomonic Barley-Sugar Column",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Spiraling helical shaft column",
    "params": [
      {
        "key": "radius",
        "name": "Shaft Radius",
        "val": 0.25,
        "min": 0.15,
        "max": 0.7,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.6,
        "min": 2.0,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "twists",
        "name": "Spiral Turns",
        "val": 3,
        "min": 1,
        "max": 8,
        "step": 1,
        "unit": "turns"
      }
    ],
    "quick": false
  },
  {
    "id": "col_tree_y",
    "name": "Y-Branched Tree Column",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Modern bio-morphic column splitting into diagonal canopy arms",
    "params": [
      {
        "key": "trunk_h",
        "name": "Trunk Height",
        "val": 2.4,
        "min": 1.5,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "branch_h",
        "name": "Branch Arm Height",
        "val": 1.5,
        "min": 0.8,
        "max": 4.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "spread",
        "name": "Top Arm Spread",
        "val": 2.2,
        "min": 1.0,
        "max": 5.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "col_chamfer",
    "name": "Chamfered Concrete Parking Pier",
    "category": "columns",
    "icon": "\uf1ad",
    "desc": "Heavy square column with 45-degree corner chamfers",
    "params": [
      {
        "key": "width",
        "name": "Width / Depth",
        "val": 0.5,
        "min": 0.3,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "chamfer",
        "name": "Corner Chamfer",
        "val": 0.05,
        "min": 0.02,
        "max": 0.15,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.2,
        "min": 2.0,
        "max": 7.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_i_beam",
    "name": "I-Beam (Wide Flange)",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Standard AISC W-profile wide flange structural beam",
    "params": [
      {
        "key": "length",
        "name": "Beam Length",
        "val": 6.0,
        "min": 1.0,
        "max": 24.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Section Depth (d)",
        "val": 0.3,
        "min": 0.1,
        "max": 1.2,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "flange_w",
        "name": "Flange Width (bf)",
        "val": 0.18,
        "min": 0.08,
        "max": 0.5,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "web_t",
        "name": "Web Thickness (tw)",
        "val": 0.015,
        "min": 0.006,
        "max": 0.04,
        "step": 0.002,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "sec_h_beam",
    "name": "H-Beam (Universal Column)",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Equal width and depth heavy structural column profile",
    "params": [
      {
        "key": "length",
        "name": "Column Length",
        "val": 4.0,
        "min": 1.0,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "size",
        "name": "Depth & Flange Size",
        "val": 0.25,
        "min": 0.15,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Flange Thickness",
        "val": 0.02,
        "min": 0.01,
        "max": 0.05,
        "step": 0.002,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "sec_c_channel",
    "name": "C-Channel Structural Profile",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Parallel flange channel section (PFC)",
    "params": [
      {
        "key": "length",
        "name": "Channel Length",
        "val": 4.0,
        "min": 1.0,
        "max": 16.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth",
        "val": 0.2,
        "min": 0.08,
        "max": 0.5,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "flange_w",
        "name": "Flange Width",
        "val": 0.08,
        "min": 0.04,
        "max": 0.2,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_t_section",
    "name": "T-Section Structural Bar",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Structural tee beam cut from wide flange",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 4.0,
        "min": 1.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "flange_w",
        "name": "Flange Width",
        "val": 0.15,
        "min": 0.06,
        "max": 0.4,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "stem_d",
        "name": "Stem Depth",
        "val": 0.15,
        "min": 0.06,
        "max": 0.4,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_l_angle",
    "name": "Equal Leg L-Angle Iron",
    "category": "structural",
    "icon": "\uf547",
    "desc": "90-degree angle iron section for bracing and clips",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 3.0,
        "min": 0.5,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "leg",
        "name": "Leg Length",
        "val": 0.1,
        "min": 0.04,
        "max": 0.25,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Thickness",
        "val": 0.01,
        "min": 0.004,
        "max": 0.03,
        "step": 0.001,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_shs_tube",
    "name": "Square Hollow Structural Tube (HSS)",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Cold-formed hollow square steel section",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 5.0,
        "min": 1.0,
        "max": 16.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "size",
        "name": "Outside Dimension",
        "val": 0.15,
        "min": 0.05,
        "max": 0.45,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "wall_t",
        "name": "Wall Thickness",
        "val": 0.008,
        "min": 0.003,
        "max": 0.025,
        "step": 0.001,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_rhs_tube",
    "name": "Rectangular Hollow Section (RHS)",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Rectangular structural steel box tubing",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 5.0,
        "min": 1.0,
        "max": 16.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Outside Depth",
        "val": 0.25,
        "min": 0.08,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Outside Width",
        "val": 0.15,
        "min": 0.05,
        "max": 0.35,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_pipe_chs",
    "name": "Circular Hollow Section (Pipe CHS)",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Round structural steel pipe or column tube",
    "params": [
      {
        "key": "length",
        "name": "Pipe Length",
        "val": 6.0,
        "min": 1.0,
        "max": 18.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "diameter",
        "name": "Outer Diameter",
        "val": 0.2,
        "min": 0.05,
        "max": 0.8,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "wall_t",
        "name": "Wall Thickness",
        "val": 0.01,
        "min": 0.003,
        "max": 0.03,
        "step": 0.001,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_z_purlin",
    "name": "Cold-Formed Z-Purlin",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Roof purlin section with overlapping nesting lips",
    "params": [
      {
        "key": "length",
        "name": "Span Length",
        "val": 6.0,
        "min": 2.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth (Web)",
        "val": 0.2,
        "min": 0.1,
        "max": 0.35,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "flange",
        "name": "Flange Width",
        "val": 0.065,
        "min": 0.04,
        "max": 0.1,
        "step": 0.005,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_castellated",
    "name": "Castellated Hex-Cell Beam",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Expanded steel beam with hexagonal web openings",
    "params": [
      {
        "key": "length",
        "name": "Beam Length",
        "val": 10.0,
        "min": 4.0,
        "max": 24.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Expanded Depth",
        "val": 0.6,
        "min": 0.3,
        "max": 1.5,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "cells",
        "name": "Cell Count",
        "val": 12,
        "min": 4,
        "max": 25,
        "step": 1,
        "unit": "holes"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_box_girder",
    "name": "Welded Steel Box Girder",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Heavy bridge girder built of 4 welded plates",
    "params": [
      {
        "key": "length",
        "name": "Girder Span",
        "val": 14.0,
        "min": 6.0,
        "max": 35.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Girder Height",
        "val": 0.9,
        "min": 0.4,
        "max": 2.5,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Girder Width",
        "val": 0.5,
        "min": 0.25,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_truss_chord",
    "name": "Truss Chord Double Angle Member",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Back-to-back double angle chord with gusset gap",
    "params": [
      {
        "key": "length",
        "name": "Chord Length",
        "val": 6.0,
        "min": 2.0,
        "max": 18.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "angle_s",
        "name": "Angle Leg Size",
        "val": 0.09,
        "min": 0.05,
        "max": 0.18,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "gap",
        "name": "Gusset Plate Gap",
        "val": 0.012,
        "min": 0.008,
        "max": 0.025,
        "step": 0.002,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_cross_brace",
    "name": "Diagonal X-Bracing Rod Set",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Tension cross-bracing diagonals with turnbuckle center",
    "params": [
      {
        "key": "width",
        "name": "Bay Width",
        "val": 6.0,
        "min": 3.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Bay Height",
        "val": 3.5,
        "min": 2.5,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "rod_dia",
        "name": "Rod Diameter",
        "val": 0.025,
        "min": 0.016,
        "max": 0.05,
        "step": 0.002,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_gusset_plate",
    "name": "Steel Connection Gusset Plate",
    "category": "structural",
    "icon": "\uf1b2",
    "desc": "Trapezoidal plate for bolted or welded truss nodes",
    "params": [
      {
        "key": "width",
        "name": "Plate Width",
        "val": 0.6,
        "min": 0.25,
        "max": 1.5,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Plate Height",
        "val": 0.45,
        "min": 0.2,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Plate Thickness",
        "val": 0.016,
        "min": 0.008,
        "max": 0.035,
        "step": 0.002,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_base_plate",
    "name": "Column Baseplate with Anchor Holes",
    "category": "structural",
    "icon": "\uf1b2",
    "desc": "Heavy steel baseplate for transferring column loads",
    "params": [
      {
        "key": "size",
        "name": "Baseplate Size",
        "val": 0.5,
        "min": 0.25,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Thickness",
        "val": 0.035,
        "min": 0.015,
        "max": 0.08,
        "step": 0.005,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_anchor_cluster",
    "name": "4-Bolt Anchor Cluster Group",
    "category": "structural",
    "icon": "\uf1b2",
    "desc": "Foundation threaded anchor bolts pattern with nuts",
    "params": [
      {
        "key": "bolt_spacing",
        "name": "Bolt Center Spacing",
        "val": 0.3,
        "min": 0.15,
        "max": 0.8,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "bolt_dia",
        "name": "Bolt Diameter",
        "val": 0.025,
        "min": 0.016,
        "max": 0.045,
        "step": 0.002,
        "unit": "m"
      },
      {
        "key": "embed_l",
        "name": "Embedment Length",
        "val": 0.5,
        "min": 0.3,
        "max": 1.0,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_grade_beam",
    "name": "Reinforced Concrete Grade Beam",
    "category": "structural",
    "icon": "\uf1b2",
    "desc": "Perimeter foundation beam spanning between pile caps",
    "params": [
      {
        "key": "length",
        "name": "Beam Span",
        "val": 6.0,
        "min": 2.0,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Beam Width",
        "val": 0.4,
        "min": 0.25,
        "max": 0.8,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Beam Depth",
        "val": 0.6,
        "min": 0.35,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_pier_found",
    "name": "Concrete Drill Shaft Caisson Pier",
    "category": "structural",
    "icon": "\uf1ad",
    "desc": "Deep foundation round pier socket",
    "params": [
      {
        "key": "diameter",
        "name": "Pier Diameter",
        "val": 0.75,
        "min": 0.4,
        "max": 2.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Embedment Depth",
        "val": 4.5,
        "min": 2.0,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_timber_post",
    "name": "Solid Heavy Timber Post (Glulam)",
    "category": "structural",
    "icon": "\uf1ad",
    "desc": "Mass timber square architectural structural column",
    "params": [
      {
        "key": "size",
        "name": "Cross Section",
        "val": 0.25,
        "min": 0.14,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Post Height",
        "val": 3.6,
        "min": 2.0,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_glulam_beam",
    "name": "Glulam Curved Architectural Beam",
    "category": "structural",
    "icon": "\uf5ee",
    "desc": "Laminated curved mass timber roof beam",
    "params": [
      {
        "key": "span",
        "name": "Clear Span",
        "val": 12.0,
        "min": 4.0,
        "max": 28.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "rise",
        "name": "Arch Camber Rise",
        "val": 1.2,
        "min": 0.4,
        "max": 3.5,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Beam Depth",
        "val": 0.55,
        "min": 0.3,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_castell_girder",
    "name": "Heavy Castellated Transfer Girder",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Large span castellated floor transfer beam",
    "params": [
      {
        "key": "span",
        "name": "Span Length",
        "val": 14.0,
        "min": 6.0,
        "max": 28.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Girder Depth",
        "val": 0.85,
        "min": 0.45,
        "max": 1.8,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_steel_joist",
    "name": "Open-Web Steel Joist (Bar Joist K-Series)",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Lightweight lattice joist for roof & floor decks",
    "params": [
      {
        "key": "span",
        "name": "Joist Span",
        "val": 9.0,
        "min": 4.0,
        "max": 20.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Joist Depth",
        "val": 0.45,
        "min": 0.25,
        "max": 1.0,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_flitch_beam",
    "name": "Flitch Composite Timber/Steel Beam",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Steel plate sandwiched between two wood joists",
    "params": [
      {
        "key": "length",
        "name": "Beam Length",
        "val": 5.0,
        "min": 2.0,
        "max": 10.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth",
        "val": 0.25,
        "min": 0.15,
        "max": 0.45,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "total_w",
        "name": "Total Width",
        "val": 0.12,
        "min": 0.08,
        "max": 0.25,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_tie_rod",
    "name": "Structural Tie Rod with Clevis Ends",
    "category": "structural",
    "icon": "\uf547",
    "desc": "Pin-connected tension rod assembly",
    "params": [
      {
        "key": "length",
        "name": "Pin-to-Pin Length",
        "val": 4.5,
        "min": 1.5,
        "max": 12.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "rod_dia",
        "name": "Bar Diameter",
        "val": 0.032,
        "min": 0.016,
        "max": 0.075,
        "step": 0.002,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "sec_cable_stay",
    "name": "High-Tensile Wire Cable Stay",
    "category": "structural",
    "icon": "\uf5ee",
    "desc": "Spiral strand tension bridge/canopy cable with socket",
    "params": [
      {
        "key": "length",
        "name": "Cable Length",
        "val": 12.0,
        "min": 3.0,
        "max": 40.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "diameter",
        "name": "Cable Diameter",
        "val": 0.038,
        "min": 0.012,
        "max": 0.1,
        "step": 0.002,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_gable",
    "name": "Classic Gable Pitch Roof",
    "category": "roofs",
    "icon": "\uf015",
    "desc": "Traditional two-sided peaked architectural roof",
    "params": [
      {
        "key": "width",
        "name": "Span Width",
        "val": 8.0,
        "min": 4.0,
        "max": 20.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Ridge Length",
        "val": 12.0,
        "min": 4.0,
        "max": 30.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "pitch",
        "name": "Roof Pitch Angle",
        "val": 30.0,
        "min": 15.0,
        "max": 55.0,
        "step": 2.5,
        "unit": "\u00b0"
      }
    ],
    "quick": true
  },
  {
    "id": "roof_hip",
    "name": "Hip Roof (4 Slopes)",
    "category": "roofs",
    "icon": "\uf015",
    "desc": "Four-sided pyramidal sloping hipped roof",
    "params": [
      {
        "key": "width",
        "name": "Span Width",
        "val": 8.0,
        "min": 4.0,
        "max": 20.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Total Length",
        "val": 12.0,
        "min": 4.0,
        "max": 30.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "pitch",
        "name": "Pitch Angle",
        "val": 28.0,
        "min": 15.0,
        "max": 50.0,
        "step": 2.0,
        "unit": "\u00b0"
      }
    ],
    "quick": true
  },
  {
    "id": "roof_shed",
    "name": "Shed / Mono-Pitch Roof",
    "category": "roofs",
    "icon": "\uf015",
    "desc": "Contemporary single-plane slanted studio roof",
    "params": [
      {
        "key": "width",
        "name": "Span Width",
        "val": 6.0,
        "min": 3.0,
        "max": 18.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length",
        "val": 9.0,
        "min": 3.0,
        "max": 24.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "pitch",
        "name": "Slope Angle",
        "val": 12.0,
        "min": 4.0,
        "max": 35.0,
        "step": 1.0,
        "unit": "\u00b0"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_gambrel",
    "name": "Gambrel Barn Roof",
    "category": "roofs",
    "icon": "\uf015",
    "desc": "Two-pitch symmetrical roof with steep lower slope",
    "params": [
      {
        "key": "width",
        "name": "Span Width",
        "val": 8.0,
        "min": 5.0,
        "max": 18.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length",
        "val": 12.0,
        "min": 5.0,
        "max": 30.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Total Roof Height",
        "val": 3.8,
        "min": 2.0,
        "max": 7.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_mansard",
    "name": "Mansard French Curb Roof",
    "category": "roofs",
    "icon": "\uf015",
    "desc": "Four-sided double slope roof with dormer capacity",
    "params": [
      {
        "key": "width",
        "name": "Width",
        "val": 10.0,
        "min": 6.0,
        "max": 24.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length",
        "val": 14.0,
        "min": 6.0,
        "max": 30.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Mansard Story Height",
        "val": 3.2,
        "min": 2.2,
        "max": 5.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_butterfly",
    "name": "Butterfly Inverted V-Roof",
    "category": "roofs",
    "icon": "\uf015",
    "desc": "Mid-century inverted roof dipping to center valley",
    "params": [
      {
        "key": "width",
        "name": "Span Width",
        "val": 8.0,
        "min": 5.0,
        "max": 18.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length",
        "val": 12.0,
        "min": 5.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "pitch",
        "name": "Upward Wing Tilt",
        "val": 14.0,
        "min": 6.0,
        "max": 25.0,
        "step": 1.0,
        "unit": "\u00b0"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_barrel",
    "name": "Curved Vaulted Barrel Roof",
    "category": "roofs",
    "icon": "\uf5ee",
    "desc": "Curving segmental cylindrical roof envelope",
    "params": [
      {
        "key": "span",
        "name": "Span",
        "val": 9.0,
        "min": 4.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length",
        "val": 15.0,
        "min": 5.0,
        "max": 40.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "rise",
        "name": "Center Arch Rise",
        "val": 1.8,
        "min": 0.6,
        "max": 5.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_dome_geo",
    "name": "Geodesic Hemispherical Dome",
    "category": "roofs",
    "icon": "\uf5ee",
    "desc": "Triangulated geodesic spherical dome frame",
    "params": [
      {
        "key": "radius",
        "name": "Base Radius",
        "val": 4.5,
        "min": 2.0,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "frequency",
        "name": "Subdivision (V)",
        "val": 3,
        "min": 1,
        "max": 6,
        "step": 1,
        "unit": "V"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_pyramid_sky",
    "name": "Pyramid Glass Skylight",
    "category": "roofs",
    "icon": "\uf1b2",
    "desc": "Four-sided glass pyramid lantern for daylighting",
    "params": [
      {
        "key": "base_size",
        "name": "Square Base Size",
        "val": 2.4,
        "min": 1.0,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Apex Height",
        "val": 1.4,
        "min": 0.6,
        "max": 3.5,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_sawtooth",
    "name": "Sawtooth Industrial Factory Roof",
    "category": "roofs",
    "icon": "\uf015",
    "desc": "Multiple asymmetrical bays with vertical glass clerestory",
    "params": [
      {
        "key": "bays",
        "name": "Number of Bays",
        "val": 3,
        "min": 2,
        "max": 8,
        "step": 1,
        "unit": "bays"
      },
      {
        "key": "bay_width",
        "name": "Bay Width",
        "val": 4.0,
        "min": 2.5,
        "max": 8.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length",
        "val": 15.0,
        "min": 5.0,
        "max": 35.0,
        "step": 1.0,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "roof_flat_deck",
    "name": "Commercial Flat Roof with Parapet",
    "category": "roofs",
    "icon": "\uf1b2",
    "desc": "Low slope built-up roof with raised perimeter parapet",
    "params": [
      {
        "key": "width",
        "name": "Width (X)",
        "val": 12.0,
        "min": 4.0,
        "max": 35.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length (Y)",
        "val": 18.0,
        "min": 4.0,
        "max": 50.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "parapet_h",
        "name": "Parapet Height",
        "val": 1.1,
        "min": 0.6,
        "max": 1.8,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "truss_king_post",
    "name": "King Post Timber Truss",
    "category": "roofs",
    "icon": "\uf547",
    "desc": "Traditional triangular truss with single center vertical post",
    "params": [
      {
        "key": "span",
        "name": "Truss Span",
        "val": 8.0,
        "min": 4.0,
        "max": 16.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "rise",
        "name": "Truss Rise",
        "val": 2.2,
        "min": 1.0,
        "max": 5.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "truss_queen_post",
    "name": "Queen Post Timber Truss",
    "category": "roofs",
    "icon": "\uf547",
    "desc": "Double vertical tie truss for wider architectural spans",
    "params": [
      {
        "key": "span",
        "name": "Truss Span",
        "val": 10.0,
        "min": 6.0,
        "max": 18.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "rise",
        "name": "Truss Rise",
        "val": 2.6,
        "min": 1.2,
        "max": 5.5,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "truss_pratt",
    "name": "Pratt Steel Pitch Truss",
    "category": "roofs",
    "icon": "\uf547",
    "desc": "Tension diagonal web members sloping toward center",
    "params": [
      {
        "key": "span",
        "name": "Truss Span",
        "val": 12.0,
        "min": 6.0,
        "max": 24.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "rise",
        "name": "Center Rise",
        "val": 2.5,
        "min": 1.2,
        "max": 6.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "panels",
        "name": "Panel Count",
        "val": 6,
        "min": 4,
        "max": 12,
        "step": 2,
        "unit": "panels"
      }
    ],
    "quick": false
  },
  {
    "id": "truss_warren",
    "name": "Warren Parallel Chord Truss",
    "category": "roofs",
    "icon": "\uf547",
    "desc": "Equilateral alternating diagonal web truss",
    "params": [
      {
        "key": "span",
        "name": "Span Length",
        "val": 12.0,
        "min": 6.0,
        "max": 28.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Truss Depth",
        "val": 1.4,
        "min": 0.8,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_box",
    "name": "Parametric Box / Cube",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Standard 6-sided solid rectangular prism",
    "params": [
      {
        "key": "width",
        "name": "Width (X)",
        "val": 4.0,
        "min": 0.5,
        "max": 30.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth (Y)",
        "val": 4.0,
        "min": 0.5,
        "max": 30.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height (Z)",
        "val": 3.0,
        "min": 0.5,
        "max": 30.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "prim_cylinder",
    "name": "Solid Cylinder",
    "category": "primitives",
    "icon": "\uf1c0",
    "desc": "Parametric round extruded solid cylinder",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 1.2,
        "min": 0.2,
        "max": 10.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.5,
        "min": 0.5,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "segments",
        "name": "Segments",
        "val": 24,
        "min": 8,
        "max": 64,
        "step": 4,
        "unit": "edges"
      }
    ],
    "quick": true
  },
  {
    "id": "prim_sphere",
    "name": "Parametric UV Sphere",
    "category": "primitives",
    "icon": "\uf111",
    "desc": "Tessellated geodesic or lat/long solid sphere",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 1.5,
        "min": 0.2,
        "max": 12.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "segments",
        "name": "Segments",
        "val": 24,
        "min": 8,
        "max": 48,
        "step": 4,
        "unit": "edges"
      }
    ],
    "quick": true
  },
  {
    "id": "prim_cone",
    "name": "Solid Cone",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Conical solid tapering from circular base to apex point",
    "params": [
      {
        "key": "radius",
        "name": "Base Radius",
        "val": 1.5,
        "min": 0.2,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.0,
        "min": 0.5,
        "max": 15.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_trunc_cone",
    "name": "Truncated Cone (Frustum)",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Cone with flat horizontal planar top cutoff",
    "params": [
      {
        "key": "base_r",
        "name": "Base Radius",
        "val": 1.6,
        "min": 0.4,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "top_r",
        "name": "Top Radius",
        "val": 0.8,
        "min": 0.2,
        "max": 6.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 2.8,
        "min": 0.5,
        "max": 12.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_pyramid",
    "name": "Square-Based Pyramid",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Classic four-sided pyramid with square base",
    "params": [
      {
        "key": "base",
        "name": "Base Size",
        "val": 3.0,
        "min": 0.5,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Apex Height",
        "val": 3.0,
        "min": 0.5,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_tri_prism",
    "name": "Triangular Prism",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Extruded equilateral or right triangular solid",
    "params": [
      {
        "key": "side",
        "name": "Triangle Base",
        "val": 2.0,
        "min": 0.5,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Extrusion Length",
        "val": 4.0,
        "min": 0.5,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_hex_prism",
    "name": "Hexagonal Prism",
    "category": "primitives",
    "icon": "\uf5ee",
    "desc": "6-sided honeycomb prism solid",
    "params": [
      {
        "key": "radius",
        "name": "Circumscribed Radius",
        "val": 1.5,
        "min": 0.4,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.0,
        "min": 0.5,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_oct_prism",
    "name": "Octagonal Prism",
    "category": "primitives",
    "icon": "\uf5ee",
    "desc": "8-sided prismatic architectural block",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 1.5,
        "min": 0.4,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 3.0,
        "min": 0.5,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_wedge",
    "name": "Right-Angle Wedge (Ramp Solid)",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Triangular incline wedge block",
    "params": [
      {
        "key": "width",
        "name": "Width (X)",
        "val": 2.5,
        "min": 0.5,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Run Length (Y)",
        "val": 4.0,
        "min": 0.5,
        "max": 15.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Peak Height (Z)",
        "val": 1.8,
        "min": 0.2,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_torus",
    "name": "Parametric Torus (Donut Ring)",
    "category": "primitives",
    "icon": "\uf111",
    "desc": "Circular ring revolved around central axis",
    "params": [
      {
        "key": "major_r",
        "name": "Ring Radius (R)",
        "val": 2.0,
        "min": 0.6,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "minor_r",
        "name": "Tube Radius (r)",
        "val": 0.4,
        "min": 0.08,
        "max": 2.0,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_capsule",
    "name": "Capsule / Pill Solid",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Cylinder capped with two hemispherical ends",
    "params": [
      {
        "key": "radius",
        "name": "Radius",
        "val": 0.6,
        "min": 0.15,
        "max": 3.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "cylinder_h",
        "name": "Cylinder Length",
        "val": 2.0,
        "min": 0.5,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_ellipsoid",
    "name": "Tri-Axial Ellipsoid",
    "category": "primitives",
    "icon": "\uf111",
    "desc": "Egg-shaped or flattened pebble solid",
    "params": [
      {
        "key": "rad_x",
        "name": "Radius X",
        "val": 2.0,
        "min": 0.3,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "rad_y",
        "name": "Radius Y",
        "val": 1.4,
        "min": 0.3,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "rad_z",
        "name": "Radius Z",
        "val": 1.0,
        "min": 0.3,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_tetrahedron",
    "name": "Regular Tetrahedron (4 Faces)",
    "category": "primitives",
    "icon": "\uf5ee",
    "desc": "Platonic solid with four equilateral triangular faces",
    "params": [
      {
        "key": "edge",
        "name": "Edge Length",
        "val": 2.4,
        "min": 0.5,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_octahedron",
    "name": "Regular Octahedron (8 Faces)",
    "category": "primitives",
    "icon": "\uf5ee",
    "desc": "Double-pyramid Platonic solid with eight faces",
    "params": [
      {
        "key": "radius",
        "name": "Vertex Radius",
        "val": 1.8,
        "min": 0.5,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_dodecahedron",
    "name": "Regular Dodecahedron (12 Pentagons)",
    "category": "primitives",
    "icon": "\uf5ee",
    "desc": "Twelve regular pentagonal faces",
    "params": [
      {
        "key": "radius",
        "name": "Outer Radius",
        "val": 1.8,
        "min": 0.5,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_icosahedron",
    "name": "Regular Icosahedron (20 Triangles)",
    "category": "primitives",
    "icon": "\uf5ee",
    "desc": "Twenty equilateral triangular faces",
    "params": [
      {
        "key": "radius",
        "name": "Outer Radius",
        "val": 1.8,
        "min": 0.5,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_chamfer_box",
    "name": "Chamfered Beveled Box",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Box with softened 45-degree architectural edge bevels",
    "params": [
      {
        "key": "width",
        "name": "Width (X)",
        "val": 3.0,
        "min": 0.8,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth (Y)",
        "val": 3.0,
        "min": 0.8,
        "max": 10.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height (Z)",
        "val": 2.0,
        "min": 0.5,
        "max": 8.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "bevel",
        "name": "Bevel Size",
        "val": 0.08,
        "min": 0.02,
        "max": 0.25,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_hollow_cyl",
    "name": "Hollow Open-Ended Pipe Cylinder",
    "category": "primitives",
    "icon": "\uf1c0",
    "desc": "Round cylindrical tube with wall thickness",
    "params": [
      {
        "key": "outer_r",
        "name": "Outer Radius",
        "val": 1.2,
        "min": 0.3,
        "max": 6.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Shell Thickness",
        "val": 0.12,
        "min": 0.03,
        "max": 0.4,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Length",
        "val": 4.0,
        "min": 0.5,
        "max": 20.0,
        "step": 0.5,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "prim_hollow_box",
    "name": "Hollow Box / Open Vessel",
    "category": "primitives",
    "icon": "\uf1b2",
    "desc": "Five-sided container box with open top",
    "params": [
      {
        "key": "width",
        "name": "Width (X)",
        "val": 2.5,
        "min": 0.6,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth (Y)",
        "val": 2.5,
        "min": 0.6,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height (Z)",
        "val": 1.8,
        "min": 0.4,
        "max": 6.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "wall_t",
        "name": "Wall Thickness",
        "val": 0.1,
        "min": 0.03,
        "max": 0.3,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_desk_exec",
    "name": "Executive Office Desk",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Modern cantilevered executive desk with modesty panel",
    "params": [
      {
        "key": "width",
        "name": "Desk Width",
        "val": 1.8,
        "min": 1.2,
        "max": 2.4,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Desk Depth",
        "val": 0.85,
        "min": 0.6,
        "max": 1.1,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Top Height",
        "val": 0.75,
        "min": 0.7,
        "max": 0.85,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "furn_conf_table",
    "name": "Conference Room Table",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Large race-track or rectangular conference table with pedestal bases",
    "params": [
      {
        "key": "length",
        "name": "Table Length",
        "val": 3.6,
        "min": 2.0,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Table Width",
        "val": 1.2,
        "min": 0.9,
        "max": 1.8,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Table Height",
        "val": 0.75,
        "min": 0.7,
        "max": 0.82,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_dining_tab",
    "name": "Dining Table (4-Legged)",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Solid hardwood dining table with 4 square corner legs",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 2.0,
        "min": 1.2,
        "max": 3.2,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Width",
        "val": 0.95,
        "min": 0.75,
        "max": 1.4,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 0.76,
        "min": 0.72,
        "max": 0.8,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_coffee_tab",
    "name": "Low Living Room Coffee Table",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Low-profile architectural cocktail table",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 1.2,
        "min": 0.7,
        "max": 1.8,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Width",
        "val": 0.65,
        "min": 0.45,
        "max": 1.1,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 0.42,
        "min": 0.3,
        "max": 0.55,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_chair_mini",
    "name": "Minimalist Dining Chair",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Scandinavian style chair with backrest and cushion seat",
    "params": [
      {
        "key": "width",
        "name": "Seat Width",
        "val": 0.46,
        "min": 0.38,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Seat Depth",
        "val": 0.48,
        "min": 0.4,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "seat_h",
        "name": "Seat Height",
        "val": 0.45,
        "min": 0.4,
        "max": 0.52,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "total_h",
        "name": "Backrest Height",
        "val": 0.84,
        "min": 0.75,
        "max": 1.0,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_office_chair",
    "name": "Ergonomic Task Office Chair",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "5-star base swivel chair with contoured lumbar back",
    "params": [
      {
        "key": "width",
        "name": "Base Span",
        "val": 0.65,
        "min": 0.55,
        "max": 0.75,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "seat_h",
        "name": "Seat Height",
        "val": 0.48,
        "min": 0.42,
        "max": 0.58,
        "step": 0.01,
        "unit": "m"
      },
      {
        "key": "back_h",
        "name": "Total Height",
        "val": 1.02,
        "min": 0.9,
        "max": 1.25,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_sofa_sec",
    "name": "Modular 3-Seat Sofa Block",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Contemporary upholstered 3-cushion living sofa",
    "params": [
      {
        "key": "length",
        "name": "Total Width",
        "val": 2.3,
        "min": 1.6,
        "max": 3.2,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Total Depth",
        "val": 0.95,
        "min": 0.8,
        "max": 1.15,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Backrest Height",
        "val": 0.78,
        "min": 0.65,
        "max": 0.92,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_bookshelf",
    "name": "Modular Multi-Tier Bookshelf",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Open shelving unit with configurable tier shelves",
    "params": [
      {
        "key": "width",
        "name": "Unit Width",
        "val": 1.2,
        "min": 0.6,
        "max": 2.4,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Shelf Depth",
        "val": 0.35,
        "min": 0.25,
        "max": 0.5,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Unit Height",
        "val": 2.0,
        "min": 1.0,
        "max": 2.8,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "tiers",
        "name": "Shelf Tiers",
        "val": 5,
        "min": 2,
        "max": 8,
        "step": 1,
        "unit": "shelves"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_kitchen_isl",
    "name": "Kitchen Island with Breakfast Overhang",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Solid base kitchen center island with 30cm counter overhang",
    "params": [
      {
        "key": "length",
        "name": "Island Length",
        "val": 2.4,
        "min": 1.5,
        "max": 4.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Total Depth",
        "val": 1.05,
        "min": 0.8,
        "max": 1.4,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Countertop Height",
        "val": 0.92,
        "min": 0.88,
        "max": 0.96,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "furn_base_cab",
    "name": "Kitchen Base Cabinet Run",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Standard modular counter base with kickplate recess",
    "params": [
      {
        "key": "length",
        "name": "Run Length",
        "val": 3.0,
        "min": 1.2,
        "max": 6.0,
        "step": 0.3,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Counter Depth",
        "val": 0.6,
        "min": 0.55,
        "max": 0.7,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Counter Height",
        "val": 0.9,
        "min": 0.86,
        "max": 0.94,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_wall_cab",
    "name": "Kitchen Overhead Wall Cabinet Run",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Upper hanging kitchen storage cabinet array",
    "params": [
      {
        "key": "length",
        "name": "Run Length",
        "val": 3.0,
        "min": 1.2,
        "max": 6.0,
        "step": 0.3,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Cabinet Depth",
        "val": 0.35,
        "min": 0.28,
        "max": 0.42,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Cabinet Height",
        "val": 0.75,
        "min": 0.45,
        "max": 1.1,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_wardrobe",
    "name": "Bedroom Built-In Wardrobe Closet",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Full floor-to-ceiling multi-door clothes armoire",
    "params": [
      {
        "key": "width",
        "name": "Closet Width",
        "val": 2.2,
        "min": 1.2,
        "max": 4.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Hanger Depth",
        "val": 0.65,
        "min": 0.55,
        "max": 0.75,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Full Height",
        "val": 2.4,
        "min": 2.0,
        "max": 3.0,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_bed_plat",
    "name": "Platform Bed with Headboard",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Queen/King architectural platform bed frame with integrated headboard",
    "params": [
      {
        "key": "width",
        "name": "Mattress Width",
        "val": 1.8,
        "min": 1.4,
        "max": 2.2,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Mattress Length",
        "val": 2.0,
        "min": 1.9,
        "max": 2.2,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "head_h",
        "name": "Headboard Height",
        "val": 1.05,
        "min": 0.85,
        "max": 1.4,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_media_unit",
    "name": "Floating Wall Media Console",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Wall-hung low horizontal entertainment sideboard",
    "params": [
      {
        "key": "width",
        "name": "Console Width",
        "val": 2.4,
        "min": 1.4,
        "max": 3.6,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth",
        "val": 0.45,
        "min": 0.35,
        "max": 0.55,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Cabinet Height",
        "val": 0.38,
        "min": 0.25,
        "max": 0.55,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_credenza",
    "name": "Architectural Credenza Sideboard",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Freestanding buffet storage unit on slender brass/steel legs",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 1.9,
        "min": 1.2,
        "max": 2.8,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth",
        "val": 0.48,
        "min": 0.38,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 0.82,
        "min": 0.7,
        "max": 0.95,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_reception",
    "name": "Curved Commercial Reception Counter",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Two-tier lobby greeting counter with transactional ledge",
    "params": [
      {
        "key": "length",
        "name": "Counter Length",
        "val": 3.2,
        "min": 1.8,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Total Depth",
        "val": 0.9,
        "min": 0.75,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "ledge_h",
        "name": "Privacy Ledge Height",
        "val": 1.12,
        "min": 1.05,
        "max": 1.2,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_bar_stool",
    "name": "Modern Counter Bar Stool",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Footrest circular barstool for breakfast bars & kitchen islands",
    "params": [
      {
        "key": "seat_dia",
        "name": "Seat Diameter",
        "val": 0.38,
        "min": 0.3,
        "max": 0.45,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Seat Height",
        "val": 0.68,
        "min": 0.6,
        "max": 0.8,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_plinth",
    "name": "Gallery Artwork Display Pedestal",
    "category": "furniture",
    "icon": "\uf1b2",
    "desc": "Seamless museum sculpture display block",
    "params": [
      {
        "key": "width",
        "name": "Plinth Size",
        "val": 0.5,
        "min": 0.3,
        "max": 1.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 0.95,
        "min": 0.4,
        "max": 1.4,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_locker",
    "name": "Gym & Office Steel Locker Unit",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Bank of 3 vertical louvered storage lockers",
    "params": [
      {
        "key": "width",
        "name": "Bank Width",
        "val": 1.0,
        "min": 0.35,
        "max": 2.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Depth",
        "val": 0.5,
        "min": 0.4,
        "max": 0.6,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 1.9,
        "min": 1.5,
        "max": 2.2,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "furn_bench",
    "name": "Upholstered Corridor Bench Seat",
    "category": "furniture",
    "icon": "\uf468",
    "desc": "Long backless cushioned resting bench",
    "params": [
      {
        "key": "length",
        "name": "Length",
        "val": 1.8,
        "min": 1.0,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Seat Depth",
        "val": 0.5,
        "min": 0.4,
        "max": 0.65,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Seat Height",
        "val": 0.45,
        "min": 0.38,
        "max": 0.5,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_planter_box",
    "name": "Rectangular Urban Planter Box",
    "category": "landscape",
    "icon": "\uf1b3",
    "desc": "Concrete architectural flower and shrub planter",
    "params": [
      {
        "key": "width",
        "name": "Planter Width (X)",
        "val": 2.4,
        "min": 0.8,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Planter Depth (Y)",
        "val": 0.9,
        "min": 0.4,
        "max": 2.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Planter Height (Z)",
        "val": 0.7,
        "min": 0.35,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "wall_t",
        "name": "Wall Thickness",
        "val": 0.12,
        "min": 0.05,
        "max": 0.25,
        "step": 0.01,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "land_planter_circ",
    "name": "Circular Tree Planter Basin",
    "category": "landscape",
    "icon": "\uf111",
    "desc": "Cast concrete ring planter with soil recess",
    "params": [
      {
        "key": "outer_r",
        "name": "Outer Radius",
        "val": 1.5,
        "min": 0.6,
        "max": 4.0,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Curb Height",
        "val": 0.5,
        "min": 0.25,
        "max": 1.0,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "wall_t",
        "name": "Wall Thickness",
        "val": 0.15,
        "min": 0.08,
        "max": 0.3,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_planter_tier",
    "name": "Tiered 3-Step Terraced Planter",
    "category": "landscape",
    "icon": "\uf1b3",
    "desc": "Ascending cascading landscape planting beds",
    "params": [
      {
        "key": "length",
        "name": "Total Length",
        "val": 3.6,
        "min": 1.5,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Total Width",
        "val": 2.1,
        "min": 1.2,
        "max": 4.5,
        "step": 0.15,
        "unit": "m"
      },
      {
        "key": "step_h",
        "name": "Tier Height Rise",
        "val": 0.35,
        "min": 0.2,
        "max": 0.6,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_curb_seg",
    "name": "Concrete Street Curb Segment",
    "category": "landscape",
    "icon": "\uf545",
    "desc": "Standard battered road curb profile with gutter edge",
    "params": [
      {
        "key": "length",
        "name": "Curb Length",
        "val": 6.0,
        "min": 1.0,
        "max": 20.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Curb Reveal",
        "val": 0.25,
        "min": 0.15,
        "max": 0.4,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Total Width",
        "val": 0.3,
        "min": 0.2,
        "max": 0.5,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_paving_slab",
    "name": "Modular Pavement Walkway Slabs",
    "category": "landscape",
    "icon": "\uf1b2",
    "desc": "Array of large format exterior paving flags with joints",
    "params": [
      {
        "key": "walk_w",
        "name": "Walkway Width",
        "val": 2.4,
        "min": 1.2,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "walk_l",
        "name": "Walkway Length",
        "val": 10.0,
        "min": 2.0,
        "max": 30.0,
        "step": 1.0,
        "unit": "m"
      },
      {
        "key": "slab_s",
        "name": "Slab Unit Size",
        "val": 0.6,
        "min": 0.3,
        "max": 1.2,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_pool_basin",
    "name": "Swimming Pool / Water Feature Basin",
    "category": "landscape",
    "icon": "\uf1b2",
    "desc": "Excavated concrete pool shell with coping perimeter edge",
    "params": [
      {
        "key": "length",
        "name": "Pool Length",
        "val": 8.0,
        "min": 3.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "width",
        "name": "Pool Width",
        "val": 4.0,
        "min": 2.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Water Depth",
        "val": 1.6,
        "min": 0.8,
        "max": 3.5,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "land_stepping_stones",
    "name": "Garden Stepping Stones Trail",
    "category": "landscape",
    "icon": "\uf111",
    "desc": "Series of organic circular flagstones along a path",
    "params": [
      {
        "key": "count",
        "name": "Stone Count",
        "val": 8,
        "min": 3,
        "max": 20,
        "step": 1,
        "unit": "stones"
      },
      {
        "key": "stone_dia",
        "name": "Stone Diameter",
        "val": 0.5,
        "min": 0.3,
        "max": 0.9,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "spacing",
        "name": "Center-to-Center",
        "val": 0.65,
        "min": 0.45,
        "max": 0.9,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_bollard",
    "name": "Cast Iron Security Bollard",
    "category": "landscape",
    "icon": "\uf1ad",
    "desc": "Pedestrian street traffic barrier post with domed top",
    "params": [
      {
        "key": "diameter",
        "name": "Bollard Diameter",
        "val": 0.2,
        "min": 0.12,
        "max": 0.35,
        "step": 0.02,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Height",
        "val": 0.95,
        "min": 0.6,
        "max": 1.3,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_bike_rack",
    "name": "Inverted U Bicycle Parking Rack",
    "category": "landscape",
    "icon": "\uf5ee",
    "desc": "Standard steel tubular bicycle hoop",
    "params": [
      {
        "key": "width",
        "name": "Hoop Width",
        "val": 0.9,
        "min": 0.6,
        "max": 1.4,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Hoop Height",
        "val": 0.85,
        "min": 0.7,
        "max": 1.05,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "tube_dia",
        "name": "Tube Diameter",
        "val": 0.05,
        "min": 0.038,
        "max": 0.075,
        "step": 0.005,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_park_bench",
    "name": "Outdoor Park Slat Bench with Backrest",
    "category": "landscape",
    "icon": "\uf468",
    "desc": "Cast metal frame park bench with wooden timber slats",
    "params": [
      {
        "key": "length",
        "name": "Bench Length",
        "val": 1.8,
        "min": 1.2,
        "max": 2.4,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "depth",
        "name": "Total Depth",
        "val": 0.65,
        "min": 0.5,
        "max": 0.8,
        "step": 0.05,
        "unit": "m"
      },
      {
        "key": "seat_h",
        "name": "Seat Height",
        "val": 0.45,
        "min": 0.4,
        "max": 0.52,
        "step": 0.02,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_pergola",
    "name": "Outdoor Garden Timber Pergola",
    "category": "landscape",
    "icon": "\uf1ad",
    "desc": "Four-post architectural shade arbor with overhead rafters",
    "params": [
      {
        "key": "width",
        "name": "Width (X)",
        "val": 3.6,
        "min": 2.4,
        "max": 6.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "length",
        "name": "Length (Y)",
        "val": 4.5,
        "min": 2.4,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "clear_h",
        "name": "Beam Clearance Height",
        "val": 2.6,
        "min": 2.2,
        "max": 3.5,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": true
  },
  {
    "id": "land_light_post",
    "name": "Architectural Streetlight Pole",
    "category": "landscape",
    "icon": "\uf1ad",
    "desc": "Tapered urban lighting mast with single luminaire arm",
    "params": [
      {
        "key": "height",
        "name": "Pole Height",
        "val": 5.5,
        "min": 3.0,
        "max": 12.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "arm_reach",
        "name": "Arm Overhang",
        "val": 1.4,
        "min": 0.6,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_fountain",
    "name": "Tiered Circular Water Fountain",
    "category": "landscape",
    "icon": "\uf111",
    "desc": "Classical round cascading water feature basin",
    "params": [
      {
        "key": "base_dia",
        "name": "Main Basin Diameter",
        "val": 3.6,
        "min": 1.8,
        "max": 8.0,
        "step": 0.2,
        "unit": "m"
      },
      {
        "key": "tiers",
        "name": "Fountain Tiers",
        "val": 2,
        "min": 1,
        "max": 4,
        "step": 1,
        "unit": "bowls"
      },
      {
        "key": "height",
        "name": "Total Height",
        "val": 2.2,
        "min": 1.0,
        "max": 4.5,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_retaining_step",
    "name": "Terraced Retaining Step Blocks",
    "category": "landscape",
    "icon": "\uf545",
    "desc": "Modular interlocking split-face stone garden retaining wall",
    "params": [
      {
        "key": "length",
        "name": "Wall Length",
        "val": 8.0,
        "min": 2.0,
        "max": 25.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Wall Height",
        "val": 1.2,
        "min": 0.4,
        "max": 3.0,
        "step": 0.1,
        "unit": "m"
      }
    ],
    "quick": false
  },
  {
    "id": "land_gabion_wall",
    "name": "Stone Gabion Wire Basket Wall",
    "category": "landscape",
    "icon": "\uf1b2",
    "desc": "Galvanized mesh basket filled with coarse quarry stone",
    "params": [
      {
        "key": "length",
        "name": "Wall Length",
        "val": 6.0,
        "min": 2.0,
        "max": 18.0,
        "step": 0.5,
        "unit": "m"
      },
      {
        "key": "height",
        "name": "Wall Height",
        "val": 1.0,
        "min": 0.5,
        "max": 2.5,
        "step": 0.1,
        "unit": "m"
      },
      {
        "key": "thick",
        "name": "Basket Thickness",
        "val": 0.5,
        "min": 0.3,
        "max": 1.0,
        "step": 0.05,
        "unit": "m"
      }
    ],
    "quick": false
  }
];


function getShapesByCategory(catId, searchQuery) {
    var query = (searchQuery || "").trim().toLowerCase();
    var list = [];
    for (var i = 0; i < allShapes.length; i++) {
        var s = allShapes[i];
        if (catId !== "all" && s.category !== catId) {
            continue;
        }
        if (query.length > 0) {
            var matchName = s.name.toLowerCase().indexOf(query) !== -1;
            var matchDesc = s.desc.toLowerCase().indexOf(query) !== -1;
            var matchCat = s.category.toLowerCase().indexOf(query) !== -1;
            if (!matchName && !matchDesc && !matchCat) {
                continue;
            }
        }
        list.push(s);
    }
    return list;
}

function getQuickShapes() {
    var list = [];
    for (var i = 0; i < allShapes.length; i++) {
        if (allShapes[i].quick) {
            list.push(allShapes[i]);
        }
    }
    return list;
}

function getShapeById(id) {
    for (var i = 0; i < allShapes.length; i++) {
        if (allShapes[i].id === id) {
            return allShapes[i];
        }
    }
    return allShapes[0];
}
