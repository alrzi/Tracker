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
    
    var body: some View {
        VStack(spacing: 0) {
            TrackerView(tracker: tracker, onTogglePin: onTogglePin)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
                .contextMenu {
                    Section("Modifications") {
                        Button(action: onTogglePin) {
                            Label(tracker.isPinned ? "Unpin" : "Pin", systemImage: tracker.isPinned ? "pin.slash" : "pin")
                        }
                        Button(action: onEdit) {
                            Label("Update", systemImage: "repeat.circle")
                        }
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "xmark.bin")
                    }
                }
            
            RecordView(
                trackedDays: tracker.trackedDays,
                isCompleted: tracker.isCompleted,
                color: Color(UIColor(hexString: tracker.color)!),
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
                    .font(.system(size: 16))
                    .padding(8)
                    .background(.white.opacity(0.3), in: .circle)
                
                Spacer(minLength: 8)
                
                Text(tracker.name)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .layoutPriority(1)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(UIColor(hexString: tracker.color)!), in: .rect(cornerRadius: 16))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.opacity(0.3), lineWidth: 1)
        })
        .overlay(alignment: .topTrailing) {
            Button(action: onTogglePin) {
                if tracker.isPinned {
                    Image(systemName: "pin")
                        .resizable()
                        .frame(width: 8, height: 12)
                        .symbolVariant(.fill)
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 24, height: 24)
            .padding(.top, 12)
            .padding(.trailing, 4)
        }
        .frame(height: 90)
    }
}

private struct RecordView: View {
    let trackedDays: Int
    let isCompleted: Bool
    let color: Color
    let onToggleCompletion: () -> Void
    
    var body: some View {
        HStack {
            Text(String(format: NSLocalizedString("days", comment: ""), trackedDays))
                .font(.system(size: 12))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.black)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: onToggleCompletion) {
                if isCompleted {
                    Image(systemName: "checkmark")
                        .resizable()
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, color)
                }
                else {
                    Image(systemName: "plus")
                        .resizable()
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, color)
                }
            }
            .frame(width: 34, height: 34)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
    }
}
