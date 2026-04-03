import SwiftUI

struct DashboardScreen: View {
    let model: DashboardScreenModel

    var body: some View {
        ScreenScaffold {
            ScreenHeader(title: model.title, subtitle: model.subtitle)

            InsightCard(title: model.retentionTitle) {
                InsetCard(contentPadding: 14) {
                    RetentionChart(
                        primarySeries: model.primarySeries,
                        baselineSeries: model.baselineSeries
                    )
                    .frame(height: 180)
                }
            }

            SectionHeader(title: model.knowledgeTitle)

            SoftCard(contentPadding: 20) {
                VStack(spacing: 22) {
                    ForEach(model.knowledgeMetrics) { metric in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(metric.title)
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textPrimary)

                                Spacer()

                                Text("\(Int(metric.progress * 100))%")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.color(for: metric.accent))
                            }

                            ProgressTrack(progress: metric.progress, accent: metric.accent, height: 8)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("screen.dash")
    }
}

private struct RetentionChart: View {
    let primarySeries: [Double]
    let baselineSeries: [Double]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    Divider().background(LearnNowPalette.shadowDark.opacity(0.5))
                    Spacer()
                    Divider().background(LearnNowPalette.shadowDark.opacity(0.5))
                    Spacer()
                }

                ChartAreaShape(values: primarySeries)
                    .fill(LearnNowPalette.gradient(for: .blue).opacity(0.28))

                ChartLineShape(values: baselineSeries)
                    .stroke(
                        LearnNowPalette.shadowDark,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 5])
                    )

                ChartLineShape(values: primarySeries)
                    .stroke(
                        LearnNowPalette.color(for: .blue),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )

                ForEach(primarySeries.indices, id: \.self) { index in
                    let point = point(at: index, values: primarySeries, size: geometry.size)

                    Circle()
                        .fill(LearnNowPalette.base)
                        .frame(width: 9, height: 9)
                        .overlay(
                            Circle()
                                .stroke(LearnNowPalette.color(for: .blue), lineWidth: 2)
                        )
                        .position(point)
                }
            }
        }
    }

    private func point(at index: Int, values: [Double], size: CGSize) -> CGPoint {
        let step = size.width / CGFloat(max(values.count - 1, 1))
        let x = CGFloat(index) * step
        let y = (1 - values[index]) * size.height
        return CGPoint(x: x, y: y)
    }
}

private struct ChartLineShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        Path { path in
            guard !values.isEmpty else { return }

            let step = rect.width / CGFloat(max(values.count - 1, 1))
            for index in values.indices {
                let point = CGPoint(
                    x: CGFloat(index) * step,
                    y: (1 - values[index]) * rect.height
                )

                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
        }
    }
}

private struct ChartAreaShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        var path = ChartLineShape(values: values).path(in: rect)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview("Dashboard") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        DashboardScreen(model: LearnNowFlowState.dashboardPreview.dashboardScreenModel)
    }
}
