#!/usr/bin/env python3
"""临时脚本：校验清水翡翠色板的 WCAG 对比度（正确 sRGB 线性化）。"""


def srgb_to_lin(c: float) -> float:
    c /= 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def luminance(rgb: tuple[float, float, float]) -> float:
    r, g, b = rgb
    return 0.2126 * srgb_to_lin(r) + 0.7152 * srgb_to_lin(g) + 0.0722 * srgb_to_lin(b)


def hex_rgb(h: int) -> tuple[int, int, int]:
    return ((h >> 16) & 0xFF, (h >> 8) & 0xFF, h & 0xFF)


def blend(fg, alpha, bg):
    return tuple(f * alpha + b * (1 - alpha) for f, b in zip(fg, bg))


def contrast(fg, bg) -> float:
    l1, l2 = luminance(fg), luminance(bg)
    if l1 < l2:
        l1, l2 = l2, l1
    return (l1 + 0.05) / (l2 + 0.05)


def flag(c: float, need: float = 4.5) -> str:
    if c >= need:
        return "OK"
    if c >= 3.0:
        return "ui"
    return "!!"


# --- Light mode（与 LearnNowDesignSystem.swift / Design Spec 6.3 同步）---
L_CANVAS = hex_rgb(0xF4F6F5)
L_GLASS = blend(hex_rgb(0xFFFFFF), 0.58, L_CANVAS)
L_OPAQUE = hex_rgb(0xF9FBFA)

light = {
    "textPrimary": hex_rgb(0x1E2522),
    "textSecondary": hex_rgb(0x4A5551),
    "textMuted": hex_rgb(0x7E8985),
    "brand.fg": hex_rgb(0x0B7A5C),
    "warning.fg": hex_rgb(0x8C6410),
    "danger.fg": hex_rgb(0xB4434E),
    "content.blue": hex_rgb(0x4A7089),
    "content.pink": hex_rgb(0xA4525C),
    "content.mint": hex_rgb(0x0F7258),
    "content.purple": hex_rgb(0x337873),
    "content.amber": hex_rgb(0x8C6410),
}
light_soft = {
    "brand.fg on brand.soft": (hex_rgb(0x0B7A5C), hex_rgb(0xDEF2E9)),
    "warning.fg on warning.soft": (hex_rgb(0x8C6410), hex_rgb(0xF6EEDA)),
    "danger.fg on danger.soft": (hex_rgb(0xB4434E), hex_rgb(0xF8E7E9)),
    "onBrand(white) on brand.fg": (hex_rgb(0xFFFFFF), hex_rgb(0x0B7A5C)),
    "onBrand(white) on gradient-end #0D9A6B": (hex_rgb(0xFFFFFF), hex_rgb(0x0D9A6B)),
    "onWarning(white) on warning.fg": (hex_rgb(0xFFFFFF), hex_rgb(0x8C6410)),
    "onDanger(white) on danger.fg": (hex_rgb(0xFFFFFF), hex_rgb(0xB4434E)),
    "textSec stroke on canvas (≥3)": (hex_rgb(0x4A5551), L_CANVAS),
}

# --- Dark mode ---
D_CANVAS = hex_rgb(0x0B0D0C)
D_GLASS = blend(hex_rgb(0x181C1A), 0.65, D_CANVAS)
D_OPAQUE = hex_rgb(0x181C1A)

dark = {
    "textPrimary(@0.95)": blend(hex_rgb(0xF3F6F4), 0.95, D_GLASS),
    "textSecondary": hex_rgb(0xC3CCC8),
    "textMuted": hex_rgb(0x8B9691),
    "brand.fg": hex_rgb(0x5FD3A6),
    "warning.fg": hex_rgb(0xE0C06A),
    "danger.fg": hex_rgb(0xEC9AA2),
    "content.blue": hex_rgb(0x8FB8CE),
    "content.pink": hex_rgb(0xDA9AA3),
    "content.mint": hex_rgb(0x66CDA8),
    "content.purple": hex_rgb(0x7CC7C0),
    "content.amber": hex_rgb(0xD9BC6E),
}
dark_soft = {
    "brand.fg on brand.soft": (hex_rgb(0x5FD3A6), hex_rgb(0x163529)),
    "warning.fg on warning.soft": (hex_rgb(0xE0C06A), hex_rgb(0x2B2416)),
    "danger.fg on danger.soft": (hex_rgb(0xEC9AA2), hex_rgb(0x2F1D20)),
    "onBrand(#07110D) on brand.fg": (hex_rgb(0x07110D), hex_rgb(0x5FD3A6)),
    "onBrand(#07110D) on gradient-start #47BE94": (hex_rgb(0x07110D), hex_rgb(0x47BE94)),
    "onWarning(#211A08) on warning.fg": (hex_rgb(0x211A08), hex_rgb(0xE0C06A)),
    "onDanger(#230F12) on danger.fg": (hex_rgb(0x230F12), hex_rgb(0xEC9AA2)),
    "textSec stroke on canvas (≥3)": (hex_rgb(0xC3CCC8), D_CANVAS),
}


def report(title, fgs, canvas, glass, opaque):
    print(f"\n=== {title} ===")
    print(f"{'token':28} {'canvas':>7} {'glass':>7} {'opaque':>7}")
    for name, rgb in fgs.items():
        cs = [contrast(rgb, bg) for bg in (canvas, glass, opaque)]
        flags = " ".join(f"{flag(c):3}" for c in cs)
        print(f"{name:28} {cs[0]:7.2f} {cs[1]:7.2f} {cs[2]:7.2f}   {flags}")


def report_pairs(title, pairs):
    print(f"\n--- {title} ---")
    for name, (fg, bg) in pairs.items():
        need = 3.0 if "≥3" in name or "gradient-end" in name else 4.5
        c = contrast(fg, bg)
        print(f"{name:48} {c:7.2f}   {flag(c, need)} (need {need})")


report("Light", light, L_CANVAS, L_GLASS, L_OPAQUE)
report_pairs("Light fills / UI", light_soft)
report("Dark", dark, D_CANVAS, D_GLASS, D_OPAQUE)
report_pairs("Dark fills / UI", dark_soft)
