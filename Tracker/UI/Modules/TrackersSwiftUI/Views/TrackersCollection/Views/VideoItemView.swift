//
//  TrackerItemView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 15.03.2025.
//

import Foundation
import SwiftUI
import TrackerDomain

struct TrackerItemView: View {
    let tracker: Tracker

    var body: some View {
        VStack(spacing: 12) {
            Text(tracker.emoji)
            
            Text(tracker.name)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                Text("Tracked days \(tracker.trackedDays.formatted(.number))")
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Group {
                    if tracker.isCompleted {
                        Image(systemName: "checkmark")
                            .resizable()
                            .symbolVariant(.circle.fill)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.blue, .orange)
                    }
                    else {
                        Image(systemName: "plus")
                            .resizable()
                            .symbolVariant(.circle.fill)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .green)
                    }
                }
                .frame(width: 44, height: 44)
            }
        }
        .padding(8)
        .background(.gray)
        .cornerRadius(8)
    }
}
