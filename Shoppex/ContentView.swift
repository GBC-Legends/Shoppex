//
//  ContentView.swift
//  Shoppex
//
//  Created by Dmitrii Stegailo on 2026-02-04.
//

import SwiftUI

enum AppScreen {
    case home
    case categories
    case supplies
    case tracking
}


struct ContentView: View {
    @State private var currentScreen: AppScreen = .home

    var body: some View {
        VStack {
            switch currentScreen {
                case .home:
                    HomeScreenView(currentScreen: $currentScreen)
                case .categories:
                    CategoriesScreenView(currentScreen: $currentScreen)
                case .supplies:
                    SuppliesScreenView(currentScreen: $currentScreen)
                case .tracking:
                    TrackingScreenView(currentScreen: $currentScreen)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
