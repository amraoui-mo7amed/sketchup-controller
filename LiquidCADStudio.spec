# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['desktop-app/main.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('desktop-app/main.qml', '.'),
        ('desktop-app/main.qml', 'desktop-app'),
        ('desktop-app/shapes_library.js', '.'),
        ('desktop-app/shapes_library.js', 'desktop-app'),
        ('desktop-app/assets', 'assets'),
        ('desktop-app/assets', 'desktop-app/assets'),
    ],
    hiddenimports=['httpx'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='LiquidCADStudio',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['desktop-app/assets/icon.icns'],
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='LiquidCADStudio',
)
app = BUNDLE(
    coll,
    name='LiquidCADStudio.app',
    icon='desktop-app/assets/icon.icns',
    bundle_identifier=None,
)
