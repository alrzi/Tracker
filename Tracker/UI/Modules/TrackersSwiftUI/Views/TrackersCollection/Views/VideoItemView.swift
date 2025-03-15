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
            HStack {
                VStack(alignment: .leading) {
                    Text(tracker.emoji)
                        .foregroundStyle(.black)
                    
                    Text(tracker.name)
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
                if tracker.isPinned {
                    Image(systemName: "pin")
                        .resizable()
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .orange)
                        .frame(width: 24, height: 24)
                }
            }
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            HStack {
                Text("Tracked days \(tracker.trackedDays.formatted(.number))")
                    .font(.title)                    
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                
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
        .background(Color(uiColor: UIColor(hexString: tracker.color)!))
        .cornerRadius(8)
    }
}
