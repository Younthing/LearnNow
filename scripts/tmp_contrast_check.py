#!/usr/bin/env python3
"""校验七套主题 × light/dark 的 WCAG 对比度（正确 sRGB 线性化）。

与 LearnNowThemeCatalog / Design Spec §6.3 同步。
目标：正文 ≥4.5:1，UI 部件 / 渐变亮端 onFill ≥3:1。
"""


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


# warning / danger 跨主题共用（灰金 / 灰玫瑰）
WARN_L, WARN_D = 0x8C6410, 0xE0C06A
DANGER_L, DANGER_D = 0xB4434E, 0xEC9AA2
WARN_SOFT_L, WARN_SOFT_D = 0xF6EEDA, 0x2B2416
DANGER_SOFT_L, DANGER_SOFT_D = 0xF8E7E9, 0x2F1D20
WARN_ON_L, WARN_ON_D = 0xFFFFFF, 0x211A08
DANGER_ON_L, DANGER_ON_D = 0xFFFFFF, 0x230F12


def theme(
    name,
    *,
    canvas,
    glass,
    glass_a,
    opaque,
    text_p,
    text_p_a,
    text_s,
    text_m,
    brand,
    brand_soft,
    brand_on,
    grad_start,
    grad_end,
    accents,
    dark: bool,
):
    warn = WARN_D if dark else WARN_L
    danger = DANGER_D if dark else DANGER_L
    warn_soft = WARN_SOFT_D if dark else WARN_SOFT_L
    danger_soft = DANGER_SOFT_D if dark else DANGER_SOFT_L
    warn_on = WARN_ON_D if dark else WARN_ON_L
    danger_on = DANGER_ON_D if dark else DANGER_ON_L

    C = hex_rgb(canvas)
    G = blend(hex_rgb(glass), glass_a, C)
    O = hex_rgb(opaque)
    tp = blend(hex_rgb(text_p), text_p_a, G) if text_p_a < 1 else hex_rgb(text_p)

    fgs = {
        "textPrimary": tp,
        "textSecondary": hex_rgb(text_s),
        "textMuted": hex_rgb(text_m),
        "brand.fg": hex_rgb(brand),
        "warning.fg": hex_rgb(warn),
        "danger.fg": hex_rgb(danger),
    }
    for key, hx in accents.items():
        fgs[f"content.{key}"] = hex_rgb(hx)

    soft = {
        "brand.fg on brand.soft": (hex_rgb(brand), hex_rgb(brand_soft)),
        "warning.fg on warning.soft": (hex_rgb(warn), hex_rgb(warn_soft)),
        "danger.fg on danger.soft": (hex_rgb(danger), hex_rgb(danger_soft)),
        "onBrand on brand.fg": (hex_rgb(brand_on), hex_rgb(brand)),
        "onBrand on gradient-end": (hex_rgb(brand_on), hex_rgb(grad_end)),
        "onBrand on gradient-start": (hex_rgb(brand_on), hex_rgb(grad_start)),
        "onWarning on warning.fg": (hex_rgb(warn_on), hex_rgb(warn)),
        "onDanger on danger.fg": (hex_rgb(danger_on), hex_rgb(danger)),
        "textSec stroke on canvas (≥3)": (hex_rgb(text_s), C),
    }
    return name, fgs, C, G, O, soft


THEMES = [
    theme(
        "emerald Light",
        canvas=0xF4F6F5,
        glass=0xFFFFFF,
        glass_a=0.58,
        opaque=0xF9FBFA,
        text_p=0x1E2522,
        text_p_a=1.0,
        text_s=0x4A5551,
        text_m=0x7E8985,
        brand=0x0B7A5C,
        brand_soft=0xDEF2E9,
        brand_on=0xFFFFFF,
        grad_start=0x0B7A5C,
        grad_end=0x0D9A6B,
        accents={
            "blue": 0x4A7089,
            "pink": 0xA4525C,
            "mint": 0x0F7258,
            "purple": 0x337873,
            "amber": 0x8C6410,
        },
        dark=False,
    ),
    theme(
        "emerald Dark",
        canvas=0x0B0D0C,
        glass=0x181C1A,
        glass_a=0.65,
        opaque=0x181C1A,
        text_p=0xF3F6F4,
        text_p_a=0.95,
        text_s=0xC3CCC8,
        text_m=0x8B9691,
        brand=0x5FD3A6,
        brand_soft=0x163529,
        brand_on=0x07110D,
        grad_start=0x47BE94,
        grad_end=0x5FD3A6,
        accents={
            "blue": 0x8FB8CE,
            "pink": 0xDA9AA3,
            "mint": 0x66CDA8,
            "purple": 0x7CC7C0,
            "amber": 0xD9BC6E,
        },
        dark=True,
    ),
    theme(
        "sand Light",
        canvas=0xF7F3EC,
        glass=0xFFFBF5,
        glass_a=0.58,
        opaque=0xFAF6F0,
        text_p=0x2A241C,
        text_p_a=1.0,
        text_s=0x5A5146,
        text_m=0x8A8176,
        brand=0x7A4E22,
        brand_soft=0xF0E4D4,
        brand_on=0xFFFFFF,
        grad_start=0x7A4E22,
        grad_end=0x96622E,
        accents={
            "blue": 0x5A6E7A,
            "pink": 0x9A5A55,
            "mint": 0x5F6B3A,
            "purple": 0x6B5E5A,
            "amber": 0x8C6410,
        },
        dark=False,
    ),
    theme(
        "sand Dark",
        canvas=0x120F0C,
        glass=0x1C1915,
        glass_a=0.65,
        opaque=0x1C1915,
        text_p=0xF6F1E8,
        text_p_a=0.95,
        text_s=0xC9C0B4,
        text_m=0x948B80,
        brand=0xD4A66A,
        brand_soft=0x2A2218,
        brand_on=0x1A1208,
        grad_start=0xC09050,
        grad_end=0xD4A66A,
        accents={
            "blue": 0xA0B4C0,
            "pink": 0xD4A0A0,
            "mint": 0xB0BC8A,
            "purple": 0xC0B0A8,
            "amber": 0xD9BC6E,
        },
        dark=True,
    ),
    theme(
        "ink Light",
        canvas=0xF1F4F6,
        glass=0xF8FBFC,
        glass_a=0.58,
        opaque=0xF5F8FA,
        text_p=0x1A2228,
        text_p_a=1.0,
        text_s=0x46525C,
        text_m=0x7A8790,
        brand=0x2F6170,
        brand_soft=0xD8E8ED,
        brand_on=0xFFFFFF,
        grad_start=0x2F6170,
        grad_end=0x3A7A8C,
        accents={
            "blue": 0x3D5F78,
            "pink": 0x8A5A68,
            "mint": 0x2F6B62,
            "purple": 0x4A6578,
            "amber": 0x7A6820,
        },
        dark=False,
    ),
    theme(
        "ink Dark",
        canvas=0x0A0C0E,
        glass=0x151A1E,
        glass_a=0.65,
        opaque=0x151A1E,
        text_p=0xEEF3F6,
        text_p_a=0.95,
        text_s=0xB8C4CC,
        text_m=0x849099,
        brand=0x7AB0C0,
        brand_soft=0x152028,
        brand_on=0x081014,
        grad_start=0x5A98A8,
        grad_end=0x7AB0C0,
        accents={
            "blue": 0x8FB0C8,
            "pink": 0xC8A0B0,
            "mint": 0x70C0B4,
            "purple": 0x90A8C0,
            "amber": 0xD0BC70,
        },
        dark=True,
    ),
    theme(
        "graphite Light",
        canvas=0xF3F3F4,
        glass=0xFFFFFF,
        glass_a=0.58,
        opaque=0xF7F7F8,
        text_p=0x1C1E22,
        text_p_a=1.0,
        text_s=0x4A4E55,
        text_m=0x7E828A,
        brand=0x3E444A,
        brand_soft=0xE2E4E7,
        brand_on=0xFFFFFF,
        grad_start=0x3E444A,
        grad_end=0x50565E,
        accents={
            "blue": 0x4A5E6E,
            "pink": 0x8A5A60,
            "mint": 0x4A6A5A,
            "purple": 0x5A5E6A,
            "amber": 0x7A6828,
        },
        dark=False,
    ),
    theme(
        "graphite Dark",
        canvas=0x0C0C0D,
        glass=0x18181A,
        glass_a=0.65,
        opaque=0x18181A,
        text_p=0xF0F0F2,
        text_p_a=0.95,
        text_s=0xC0C2C8,
        text_m=0x8A8C94,
        brand=0xA8ADB3,
        brand_soft=0x222428,
        brand_on=0x0C0E10,
        grad_start=0x8A9098,
        grad_end=0xA8ADB3,
        accents={
            "blue": 0x9AAEC0,
            "pink": 0xC8A0A8,
            "mint": 0x9AB8A8,
            "purple": 0xA8ACB8,
            "amber": 0xD0BC78,
        },
        dark=True,
    ),
    theme(
        "clay Light",
        canvas=0xF6F1F0,
        glass=0xFFF8F7,
        glass_a=0.58,
        opaque=0xFAF4F3,
        text_p=0x2A201E,
        text_p_a=1.0,
        text_s=0x5A4A47,
        text_m=0x8A7A76,
        brand=0x8E4E42,
        brand_soft=0xF0E0DC,
        brand_on=0xFFFFFF,
        grad_start=0x8E4E42,
        grad_end=0xA05A4C,
        accents={
            "blue": 0x5A6870,
            "pink": 0x9A5558,
            "mint": 0x5A6A48,
            "purple": 0x6A5A5E,
            "amber": 0x8C6410,
        },
        dark=False,
    ),
    theme(
        "clay Dark",
        canvas=0x100C0C,
        glass=0x1C1615,
        glass_a=0.65,
        opaque=0x1C1615,
        text_p=0xF6EEEB,
        text_p_a=0.95,
        text_s=0xC8B8B4,
        text_m=0x948884,
        brand=0xD4A090,
        brand_soft=0x2A1C1A,
        brand_on=0x180E0C,
        grad_start=0xC08070,
        grad_end=0xD4A090,
        accents={
            "blue": 0xA0B0B8,
            "pink": 0xD4A0A4,
            "mint": 0xB0BC98,
            "purple": 0xC0A8B0,
            "amber": 0xD9BC6E,
        },
        dark=True,
    ),
    theme(
        "sky Light",
        canvas=0xF8FCFE,
        glass=0xFFFFFF,
        glass_a=0.72,
        opaque=0xFBFEFF,
        text_p=0x1A252C,
        text_p_a=1.0,
        text_s=0x465660,
        text_m=0x7A8A92,
        brand=0x0E7888,
        brand_soft=0xECF9FC,
        brand_on=0xFFFFFF,
        grad_start=0x0E7888,
        grad_end=0x1898A8,
        accents={
            "blue": 0x3A7088,
            "pink": 0xA45868,
            "mint": 0x2A7888,
            "purple": 0x4A7080,
            "amber": 0x8C6410,
        },
        dark=False,
    ),
    theme(
        "sky Dark",
        canvas=0x070B0E,
        glass=0x12181C,
        glass_a=0.70,
        opaque=0x12181C,
        text_p=0xF2F8FA,
        text_p_a=0.95,
        text_s=0xB8C8D0,
        text_m=0x8898A0,
        brand=0x7AD4E4,
        brand_soft=0x102832,
        brand_on=0x051014,
        grad_start=0x54BCD0,
        grad_end=0x7AD4E4,
        accents={
            "blue": 0x92C0D4,
            "pink": 0xD8A8B8,
            "mint": 0x78C8D0,
            "purple": 0x98B8C8,
            "amber": 0xE0C878,
        },
        dark=True,
    ),
    theme(
        "citrus Light",
        canvas=0xFAFBF5,
        glass=0xFFFFFF,
        glass_a=0.72,
        opaque=0xFEFDF8,
        text_p=0x222818,
        text_p_a=1.0,
        text_s=0x525A45,
        text_m=0x828A75,
        brand=0x4C7812,
        brand_soft=0xF5FADF,
        brand_on=0xFFFFFF,
        grad_start=0x4C7812,
        grad_end=0x5E9018,
        accents={
            "blue": 0x4A7080,
            "pink": 0xA45858,
            "mint": 0x4A7818,
            "purple": 0x5A7860,
            "amber": 0x8C6410,
        },
        dark=False,
    ),
    theme(
        "citrus Dark",
        canvas=0x090B07,
        glass=0x161812,
        glass_a=0.70,
        opaque=0x161812,
        text_p=0xF6F8EE,
        text_p_a=0.95,
        text_s=0xC4CCB4,
        text_m=0x949C88,
        brand=0xC4DC70,
        brand_soft=0x1E2214,
        brand_on=0x0E1206,
        grad_start=0xA4CC48,
        grad_end=0xC4DC70,
        accents={
            "blue": 0xA0B8C8,
            "pink": 0xD8A8A8,
            "mint": 0xA8D068,
            "purple": 0xA8C8B0,
            "amber": 0xE0C878,
        },
        dark=True,
    ),
]


def report(title, fgs, canvas, glass, opaque):
    print(f"\n=== {title} ===")
    print(f"{'token':28} {'canvas':>7} {'glass':>7} {'opaque':>7}")
    failures = 0
    for name, rgb in fgs.items():
        need = 3.0 if name == "textMuted" else 4.5
        cs = [contrast(rgb, bg) for bg in (canvas, glass, opaque)]
        flags = " ".join(f"{flag(c, need):3}" for c in cs)
        print(f"{name:28} {cs[0]:7.2f} {cs[1]:7.2f} {cs[2]:7.2f}   {flags}")
        # textMuted is intentionally soft (≥3 UI); others need ≥4.5 on all surfaces
        for c in cs:
            if name == "textMuted":
                if c < 3.0:
                    failures += 1
            elif c < 4.5:
                failures += 1
    return failures


def report_pairs(title, pairs):
    print(f"\n--- {title} ---")
    failures = 0
    for name, (fg, bg) in pairs.items():
        need = 3.0 if "≥3" in name or "gradient" in name else 4.5
        c = contrast(fg, bg)
        print(f"{name:48} {c:7.2f}   {flag(c, need)} (need {need})")
        if c < need:
            failures += 1
    return failures


total_failures = 0
for name, fgs, canvas, glass, opaque, soft in THEMES:
    total_failures += report(name, fgs, canvas, glass, opaque)
    total_failures += report_pairs(f"{name} fills / UI", soft)

print(f"\n=== Summary ===")
print(f"failures: {total_failures}")
raise SystemExit(1 if total_failures else 0)
