//
//  Swift_TalkApp.swift
//  Swift Talk
//
//  Created by Ibrahim Eid on 29/10/2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ProjectMessageApp: App {
    @State private var pin = ""
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var themeManager = ThemeManager()

    @AppStorage("selectedColorScheme") private var selectedColorScheme: String = "light"
    @AppStorage("chatBackgroundColor") private var chatBackgroundColor: String = "default"


        var body: some Scene {
            WindowGroup {
               
                AuthChecker()
                    .preferredColorScheme(colorScheme)
            }
        }

        private var colorScheme: ColorScheme? {
            switch selectedColorScheme {
            case "light": return .light
            case "dark": return .dark
            default: return nil
            }
        }
}
