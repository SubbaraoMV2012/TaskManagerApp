//
//  SettingsView.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel = SettingsViewModel.shared
    
    var body: some View {
        Form {
            Section(header: Text("Accent Color")) {
                Picker("Select Color", selection: $settingsViewModel.selectedAccentColor) {
                    ForEach(AccentColor.allCases, id: \.self) { color in
                        HStack {
                            Circle()
                                .fill(color.color)
                                .frame(width: 20, height: 20)
                            Text(color.rawValue.capitalized)
                        }
                    }
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
