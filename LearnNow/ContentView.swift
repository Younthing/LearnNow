//
//  ContentView.swift
//  LearnNow
//
//  Created by fanxi on 3/31/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var store = LearnNowAppStore()

    var body: some View {
        Group {
            switch store.loadState {
            case .loading:
                LearnNowLoadingView()
            case .ready:
                AppShellView(store: store)
            case .catalogError(let message):
                LearnNowStartupErrorView(
                    title: "课程内容无法加载",
                    message: message,
                    retry: { Task { await store.load(context: modelContext, force: true) } }
                )
            case .persistenceError(let message):
                LearnNowStartupErrorView(
                    title: "学习记录无法打开",
                    message: message,
                    retry: { Task { await store.load(context: modelContext, force: true) } }
                )
            }
        }
        .preferredColorScheme(store.flow.isNightModeEnabled ? .dark : .light)
        .task { await store.load(context: modelContext) }
    }
}

private struct LearnNowLoadingView: View {
    var body: some View {
        ZStack {
            LearnNowPalette.canvas.ignoresSafeArea()
            ProgressView("正在准备课程与学习记录…")
                .font(LearnNowTypography.body)
                .tint(LearnNowPalette.color(for: .blue))
        }
        .accessibilityIdentifier("startup.loading")
    }
}

private struct LearnNowStartupErrorView: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        ZStack {
            LearnNowPalette.canvas.ignoresSafeArea()
            SoftCard(contentPadding: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(LearnNowPalette.color(for: .amber))
                    Text(title)
                        .font(LearnNowTypography.screenTitle)
                    Text(message)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textMuted)
                        .multilineTextAlignment(.center)
                    FullWidthButton(title: "重试", accent: .blue, systemImage: "arrow.clockwise", action: retry)
                }
            }
            .padding(24)
        }
        .accessibilityIdentifier("startup.error")
    }
}

#Preview {
    ContentView()
}
