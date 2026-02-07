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

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}


struct ContentView: View {
    @State private var currentScreen: AppScreen = .home

    var body: some View {
        ZStack {
            Color(hex: "#1D1E27")
                .ignoresSafeArea()

            VStack {
                LogoComponentView()

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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            // .padding()
        }
    }
}

#Preview {
    ContentView()
}
