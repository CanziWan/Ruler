//
//  RulerApp.swift
//  Ruler
//
//  Created by Canzi on 2025/1/20.
//

import SwiftUI

@main
struct RulerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 设置为横屏
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        scene.sizeRestrictions?.minimumSize = CGSize(width: 800, height: 600) // 设置最小尺寸以适应横屏
                    }
                }
        }
    }
}
