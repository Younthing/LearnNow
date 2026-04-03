# LearnNow: 新拟态 (Neumorphism) UI/UX 实践与 SwiftUI 迁移指南

本文档基于 `docs/原型-Neumorphism.html` 提取设计令牌（Design Tokens）与交互细节，并结合 **UI/UX Pro Max** 的规范要求，为 LearnNow 应用从 HTML 原型迁移至 SwiftUI 提供系统性的指导。

---

## 1. 核心设计令牌 (Design Tokens)

新拟态（Soft UI）设计严重依赖背景色、阴影色与材质的精准配合。在 SwiftUI 开发中，建议将以下定义在 `Assets.xcassets` 或 `Color` 扩展中形成统一体系。

### 1.1 配色系统 (Color Palette)

原型使用柔和的粉彩 (Pastel) 配法，极大地降低了视觉疲劳感。

- **背景底色 (Background)**
  - `bg-base` (Main Background): `#E8F0FE`

- **新拟态光影 (Shadows for Neumorphism)**
  - `shadow-dark`: `#CDD9ED` (右下角阴影)
  - `shadow-light`: `#FFFFFF` (左上角高光)

- **文本色彩 (Text Colors, 需满足 4.5:1 对比度要求)**
  - `text-h` (Heading): `#3B4A6B` (深蓝色，对比度极高)
  - `text-main` (Body): `#5C6B89` (正文，清晰易读)
  - `text-muted` (Muted/Subtitle): `#8E9EBC` (极弱化元素)

- **品牌点缀色 (Brand Accents)**
  - `brand-blue`: `#A1C4FD` (浅蓝) / `brand-blue-dark`: `#8AACEC`
  - `brand-pink`: `#FFCCD5` (浅粉) / `brand-pink-dark`: `#FFAAC3`
  - `brand-mint`: `#C2E9D2` (薄荷绿，常用于成功态)
  - `brand-purple`: `#DBCDF0` (柔和紫)

### 1.2 圆角与间距 (Radii & Spacing)

- **圆角 (Corner Radius)**: `sm` (8pt), `md` (16pt), `lg` (24pt), `xl` (32pt), `pill` (全圆角/胶囊)。在 SwiftUI 中推荐使用 `.continuous` 连续平滑圆角。
- **间距 (Spacing)**: 遵循 8pt 基准系统（例如：8, 16, 24, 32pt），保证组件留白一致。

---

## 2. 核心新拟态组件的 SwiftUI 实现模式

为了保持代码整洁，应在 SwiftUI 中编写自定义 ViewModifier 来封装新拟态视觉效果。

### 2.1 凸起效果 (Neu-Out)
用于卡片 (`neu-card`)、按钮的默认状态。

```swift
import SwiftUI

struct NeuOutModifier: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(Color("bg-base"))
            .cornerRadius(cornerRadius, antialiased: true)
            // 右下角暗色阴影
            .shadow(color: Color("shadow-dark"), radius: 10, x: 8, y: 8)
            // 左上角亮色高光
            .shadow(color: Color("shadow-light"), radius: 10, x: -8, y: -8)
    }
}

extension View {
    func neuOutStyle(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(NeuOutModifier(cornerRadius: cornerRadius))
    }
}
```

### 2.2 凹陷效果 (Neu-In)
用于输入框、进度条底槽 (`neu-progress`)、按钮按压状态 (`:active`)、激活的 Tab。

*注意：SwiftUI 的内阴影可以通过叠加带有 `.inner` 模糊效果的形状来实现。*

```swift
struct NeuInModifier: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color("bg-base"))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.gray.opacity(0.05), lineWidth: 2)
                            .shadow(color: Color("shadow-dark"), radius: 3, x: 2, y: 2)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .shadow(color: Color("shadow-light"), radius: 3, x: -2, y: -2)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    )
            )
    }
}

extension View {
    func neuInStyle(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(NeuInModifier(cornerRadius: cornerRadius))
    }
}
```

---

## 3. 遵从 UI/UX Pro Max 的实践要求

在从 Web 原型转化为 iOS 原生应用时，需严格遵循以下 `ui-ux-pro-max` 规则：

### 3.1 触摸与交互 (Touch & Interaction) / 优先级: CRITICAL
- **`touch-target-size`**: SwiftUI 中所有的按钮、可点击区块必须保证至少有 **44×44pt** 的点击区域（如导航栏返回按钮、底部 Tab 等）。
- **`hover-vs-tap` & `press-feedback`**: iOS 没有 Hover，按钮按下时需即时反馈。原型中定义了 `.neu-btn:active` 的状态。在 SwiftUI 中应该通过 `.buttonStyle` 定义高亮态（缩小 Scale 并切换到 `.neuInStyle()` 凹槽效果）。

```swift
// 缩小并切换内阴影的按钮交互示例
struct NeuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: 24).fill(Color("bg-base")).neuInStyle(cornerRadius: 24)
                    } else {
                        RoundedRectangle(cornerRadius: 24).fill(Color("bg-base")).neuOutStyle(cornerRadius: 24)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
```

### 3.2 动效系统 (Animation) / 优先级: MEDIUM
- **`duration-timing` & `spring-physics`**: 原型中所有卡片的切换和按钮点击（如 `transform: scale(0.98); animation: softFade 0.4s`）在 SwiftUI 中应尽量采用基于物理特性的弹簧动画：`.animation(.spring(response: 0.4, dampingFraction: 0.7), value: ...)`。
- **`interruptible`**: SwiftUI 的动画应当是可被打断的，避免长时间锁住主线程用户的操作。
- **动态图标 (`spin-anim`)**: 对原型中用于代表打卡的呼吸/旋转状态（如 `lucide-loader` 和 火苗跳动），SwiftUI 可使用 `withAnimation(.linear.repeatForever(autoreverses: false))` 实装。

### 3.3 可访问性与排版 (Accessibility & Typography) / 优先级: CRITICAL
- **`dynamic-type`**: 原型使用 `Nunito`。在迁移过程中，务必使用 `Font.custom("Nunito", size: 16, relativeTo: .body)` 来适配 Apple 的动态类型（Dynamic Type），以防用户在系统设置放大字体时界面失效。
- **`color-contrast`**: 虽然新拟态配色极低对比度，但原型的文本颜色（例如 `#3B4A6B` 相对背景 `#E8F0FE`）表现较好。需注意 `text-muted` (`#8E9EBC`) 颜色，如果文本太细太小（如小于12pt），在某些设备上可能没法满足 4.5:1 的对比度，可以利用 SwiftUI 的 `.bold()` 略加字重。

### 3.4 视图层次与导航 (Navigation Patterns)
- **`safe-area-awareness`**: 原型的浮岛底部导航（Floating Nav bar）在 iOS 迁移时，必须避开 Home Indicator（底栏横线）和刘海屏（Notch/Dynamic Island Area），建议将其 `bottom` 的 padding 结合系统环境变量 `safeAreaInsets.bottom` 来计算。
- **`tab-bar-ios`**: 原型的底部栏可通过隐藏默认 Tab Bar 的方式，自定义覆盖一个基于 HStack 实现的浮岛导航条，同时利用 `.matchedGeometryEffect` 给选中的 Tab 图标加上平滑的缩放和新拟态高亮切换过渡。

---

## 4. 迁移检查清单 (Migration Checklist)

1. [ ] **抽取色彩资源**：将 10 个色彩属性迁移至 Xcode 的 Attributes Inspector `Assets.xcassets`，同时配置对应的 Dark Mode（注意：**纯 Neumorphism 在深色模式下非常难以实施**，需微调深色模式下的阴影策略）。
2. [ ] **统一字体引入**：引入 Nunito 字体并映射 `h1`到`largeTitle`的尺寸层级。
3. [ ] **封装 ViewModifier**：全局实现 `NeuOut`、`NeuIn` 等结构，保证所有圆角、间距完全符合 1.2 节标准。
4. [ ] **重构布局**：用 `ZStack` 和 `VStack/HStack` 替代 Flex 布局。
5. [ ] **交互还原**：所有按钮绑定封装好的 `ButtonStyle`，结合 `haptic-feedback` 补充轻微震动反馈 (`UIImpactFeedbackGenerator`) 以弥补按压立体感的缺失（这点很重要！）。
6. [ ] **动效还原**：使用 `.transition(.opacity.combined(with: .scale))` 和弹性动画完成原型中的课时通关特效。
