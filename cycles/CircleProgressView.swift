//
//  CircleProgressView.swift
//  cycles
//
//  Created by Tony Zhang on 11/12/20.
//

import SwiftUI

struct CircleProgressView: View {
    var progress:Double
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .foregroundColor(Color.white.opacity(0.2))
            Circle()
                .trim(from: 0.0, to: CGFloat(max(min(self.progress, 1.0),0)))
                .stroke(style: StrokeStyle(lineWidth: (self.progress==0) ? 0.0 : 10.0,lineCap: .round, lineJoin: .round))
                .animation(Animation.linear(duration: 0.2))
                .foregroundColor(Color.white.opacity(0.6))
                .rotationEffect(Angle(degrees: 270.0))
                
        }
        .frame(width: 50, height: 50)
    }
}
