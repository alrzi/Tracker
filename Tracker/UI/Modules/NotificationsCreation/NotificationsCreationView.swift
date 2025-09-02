//
//  NotificationsCreationView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import Foundation
import SwiftUI

struct NotificationsCreationView<ViewModel: NotificationsCreationViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Schedule Notification")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            TextField("Notification Title", text: $viewModel.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(4)
                .shadow(color: .gray, radius: 5, x: 0, y: 2)
            
            TextField("Notification Body", text: $viewModel.subtitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(4)
                .shadow(color: .gray, radius: 5, x: 0, y: 2)
            
            DatePicker(
                "Select Time",
                selection: $viewModel.selectedDate,
                displayedComponents: .hourAndMinute
            )
            .padding(12)
            .shadow(color: .gray, radius: 5, x: 0, y: 2)
            
            Button(action: viewModel.onNotificationCreated) {
                Text("Schedule Notification")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
            }
        }
        .padding()
    }
}

#Preview {
    NotificationsCreationView(viewModel: NotificationsCreationViewModel())
}
