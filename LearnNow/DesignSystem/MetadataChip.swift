import SwiftUI

enum MetadataChipProminence {
    case subtle
    case accented
    case selected
}

struct MetadataChip: View {
    let text: String
    let accent: LearnNowAccent
    var systemImage: String? = nil
    var prominence: MetadataChipProminence = .accented
    var isExpanded = false

    private var accentColor: Color {
        LearnNowPalette.color(for: accent)
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
                    .font(.system(size: 11, weight: .black))
            }

            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .font(LearnNowTypography.label)
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
    let accent: LearnNowAccent
    let isSelected: Bool
    var isExpanded = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            MetadataChip(
                text: title,
                accent: accent,
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
