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
    let onToggleCompletion: () -> Void
    let onTogglePin: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var pinLabel: String {
        tracker.isPinned ? String(localized: .contextUnpin) : String(localized: .contextPin)
    }
    
    var pinImageName: String {
        tracker.isPinned ? "pin.slash" : "pin"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TrackerView(tracker: tracker, onTogglePin: onTogglePin)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
                .contextMenu {
                    Section("Modifications") {
                        Button(action: onTogglePin) {
                            Label(pinLabel, systemImage: pinImageName)
                        }
                        Button(action: onEdit) {
                            Label(String(localized: .contextUpdate), systemImage: "repeat.circle")
                        }
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: onDelete) {
                        Label(String(localized: .contextDelete), systemImage: "xmark.bin")
                    }
                }
            
            RecordView(
                trackedDays: tracker.trackedDays,
                isCompleted: tracker.isCompleted,
                color: Color(hexString: tracker.color) ?? .green,
                onToggleCompletion: onToggleCompletion
            )
        }
    }
}

private struct TrackerView: View {
    let tracker: Tracker
    let onTogglePin: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(tracker.emoji)
                    .font(.body)
                    .padding(8)
                    .background(.white.opacity(0.3), in: .circle)
                
                Spacer(minLength: 8)
                
                Text(tracker.name)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .layoutPriority(1)
            }
            .layoutPriority(1)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(hexString: tracker.color) ?? .green, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.opacity(0.3), lineWidth: 1)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onTogglePin) {
                if tracker.isPinned {
                    Image(systemName: "pin")
                        .font(.caption2)
                        .symbolVariant(.fill)
                        .foregroundStyle(.white)
                }
            }
            .padding(8)
            .contentShape(.rect)
            .padding(.top, 12)
            .padding(.trailing, 4)
        }
    }
}

private struct RecordView: View {
    let trackedDays: Int
    let isCompleted: Bool
    let color: Color
    let onToggleCompletion: () -> Void
    
    var body: some View {
        HStack {
            Text(.days(Int32(trackedDays)))
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: onToggleCompletion) {
                Image(systemName: isCompleted ? "checkmark" : "plus")
                    .font(.largeTitle)
                    .symbolVariant(.circle.fill)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        .white,
                        isCompleted ? color.opacity(0.3) : color
                    )
            }
            .padding(4)
            .contentShape(.circle)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
    }
}
