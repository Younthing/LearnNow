import SwiftUI

enum MetadataChipProminence {
    case subtle
    case accented
    case selected
}

struct MetadataChip: View {
    let text: String
    var systemImage: String? = nil
    var prominence: MetadataChipProminence = .accented
    var isExpanded = false
    private let accentColor: Color
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        text: String,
        accent: LearnNowAccent,
        systemImage: String? = nil,
        prominence: MetadataChipProminence = .accented,
        isExpanded: Bool = false
    ) {
        self.init(
            text: text,
            accentColor: LearnNowPalette.color(for: accent),
            systemImage: systemImage,
            prominence: prominence,
            isExpanded: isExpanded
        )
    }

    init(
        text: String,
        role: LearnNowSemanticRole,
        systemImage: String? = nil,
        prominence: MetadataChipProminence = .accented,
        isExpanded: Bool = false
    ) {
        self.init(
            text: text,
            accentColor: role.foreground,
            systemImage: systemImage,
            prominence: prominence,
            isExpanded: isExpanded
        )
    }

    fileprivate init(
        text: String,
        accentColor: Color,
        systemImage: String? = nil,
        prominence: MetadataChipProminence = .accented,
        isExpanded: Bool = false
    ) {
        self.text = text
        self.systemImage = systemImage
        self.prominence = prominence
        self.isExpanded = isExpanded
        self.accentColor = accentColor
    }

    private var foregroundColor: Color {
        switch prominence {
        case .subtle:
            return LearnNowPalette.textSecondary
        case .accented, .selected:
            return accentColor
        }
    }

    private var backgroundOpacity: Double {
        switch prominence {
        case .subtle:
            return 0.06
        case .accented:
            return 0.11
        case .selected:
            return 0.17
        }
    }

    private var strokeOpacity: Double {
        switch prominence {
        case .subtle:
            return 0.12
        case .accented:
            return 0.20
        case .selected:
            return 0.38
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.bold))
            }

            Text(text)
                .font(LearnNowTypography.label)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .frame(maxWidth: isExpanded ? .infinity : nil, minHeight: 30)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(accentColor.opacity(backgroundOpacity))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(accentColor.opacity(strokeOpacity), lineWidth: 0.75)
        }
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct MetadataChipButton: View {
    let title: String
    let isSelected: Bool
    var isExpanded = false
    let action: () -> Void
    private let accentColor: Color

    init(
        title: String,
        accent: LearnNowAccent,
        isSelected: Bool,
        isExpanded: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.isExpanded = isExpanded
        self.action = action
        self.accentColor = LearnNowPalette.color(for: accent)
    }

    init(
        title: String,
        role: LearnNowSemanticRole,
        isSelected: Bool,
        isExpanded: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.isExpanded = isExpanded
        self.action = action
        self.accentColor = role.foreground
    }

    var body: some View {
        Button(action: action) {
            MetadataChip(
                text: title,
                accentColor: accentColor,
                systemImage: isSelected ? "checkmark" : nil,
                prominence: isSelected ? .selected : .subtle,
                isExpanded: isExpanded
            )
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(MetadataChipPressStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityValue(isSelected ? "已选择" : "未选择")
    }
}

private struct MetadataChipPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
