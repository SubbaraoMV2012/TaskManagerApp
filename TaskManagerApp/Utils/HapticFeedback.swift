//
//  HapticFeedback.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 28/02/25.
//

import UIKit

struct HapticFeedback {
    static func trigger() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
