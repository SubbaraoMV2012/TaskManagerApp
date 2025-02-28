//
//  SettingsViewModel.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 01/03/25.
//

import Foundation
import SwiftUI

enum AccentColor: String, CaseIterable, Identifiable {
    case blue, green, red, orange, purple
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .red: return .red
        case .orange: return .orange
        case .purple: return .purple
        }
    }
}

class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    @Published var selectedAccentColor: AccentColor {
        didSet {
            UserDefaults.standard.set(selectedAccentColor.rawValue, forKey: "AccentColor")
        }
    }
    
    private init() {
        let savedColor = UserDefaults.standard.string(forKey: "AccentColor") ?? AccentColor.blue.rawValue
        self.selectedAccentColor = AccentColor(rawValue: savedColor) ?? .blue
    }
}
