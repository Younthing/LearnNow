//
//  ContentView.swift
//  LearnNow
//
//  Created by fanxi on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var flow = LearnNowFlowState()

    var body: some View {
        AppShellView(flow: $flow)
            .preferredColorScheme(flow.isNightModeEnabled ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
