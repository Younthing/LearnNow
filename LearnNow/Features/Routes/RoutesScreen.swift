import SwiftUI

struct RoutesScreen: View {
    let flow: LearnNowFlowState
    let onOpenCurrentRoute: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ScreenHeader(title: "学习路线", subtitle: "选择你的探索方向")

                VStack(spacing: 20) {
                    ForEach(flow.routes) { route in
                        RouteCard(route: route) {
                            if route.interactive {
                                onOpenCurrentRoute()
                            }
                        }
                        .accessibilityIdentifier(route.id == "datascience" ? "route.datascience" : "")
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .accessibilityIdentifier("screen.routes")
    }
}

private struct RouteCard: View {
    let route: LearnNowRoute
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SoftCard(contentPadding: 20) {
                HStack(alignment: .top, spacing: 16) {
                    InsetCircle(size: 52) {
                        Image(systemName: iconName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(LearnNowPalette.color(for: route.accent))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(route.title)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .multilineTextAlignment(.leading)

                        Text(route.subtitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)
                            .multilineTextAlignment(.leading)

                        HStack {
                            Text(route.progress == 0 ? "未开始" : "已完成 \(Int(route.progress * 100))%")
                            Spacer()
                            Text(route.cta)
                                .foregroundStyle(LearnNowPalette.color(for: route.accent))
                        }
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textMuted)

                        ProgressTrack(progress: route.progress, accent: route.accent, height: 6)
                    }
                }
            }
            .opacity(route.interactive ? 1 : 0.96)
        }
        .buttonStyle(.plain)
        .disabled(!route.interactive)
    }

    private var iconName: String {
        switch route.id {
        case "datascience":
            "cpu"
        case "design":
            "paintpalette"
        default:
            "chevron.left.forwardslash.chevron.right"
        }
    }
}

#Preview("Routes") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        RoutesScreen(flow: .routesPreview, onOpenCurrentRoute: {})
    }
}
