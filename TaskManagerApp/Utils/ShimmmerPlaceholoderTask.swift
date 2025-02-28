//
//  ShimmmerPlaceholoderTask.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 01/03/25.
//

import SwiftUI

struct ShimmerEffect: View {
    @State private var opacity: Double = 0.3
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(opacity))
            .frame(height: 20)
            .frame(maxWidth: .infinity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    opacity = 0.7
                }
            }
    }
}

struct ShimmmerPlaceholoderTask: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 30, height: 30)
            
            ShimmerEffect() 
        }
        .padding(.vertical, 5)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
    }
}

#Preview {
    ShimmmerPlaceholoderTask()
}
