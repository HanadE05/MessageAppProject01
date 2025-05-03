import SwiftUI

enum Theme {
    case light
    case dark

    var foreground: Color {
        switch self {
        case .light:
            return .black
        case .dark:
            return .white
     
        }
    }

    var background: Color {
        switch self {
        case .light:
            return .white
        case .dark:
            return .black

        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme = .light

    var foreground: Color {
        currentTheme.foreground
    }

    var background: Color {
        currentTheme.background
    }
}
