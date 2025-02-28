//
//  RingProgressBar.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import SwiftUI

struct RingProgressBar: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress / 100))
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [.blue, .green]), center: .center),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
            
            Text("\(Int(progress))%")
                .font(.title2)
                .bold()
        }
        .frame(width: 100, height: 100)
    }
}

#Preview {
    RingProgressBar(progress: 50)
}
