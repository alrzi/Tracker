//
//  TrackerFormHabitScheduleView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/14/26.
//

import SwiftUI

struct TrackerFormHabitScheduleView: View {
    @ObservedObject var viewModel: TrackerFormHabitScheduleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Дни и напоминания")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(viewModel.configs, id: \.day) { config in
                    DayColumnView(
                        config: config,
                        onToggleDay: { viewModel.toggleDay(config.day) },
                        onToggleNotification: { viewModel.toggleNotification(for: config.day) },
                        onTimeChanged: { time in viewModel.update(config.day, with: time) },
                    )
                }
            }
        }
        .padding()
        .alert("Уведомления отключены", isPresented: $viewModel.showPermissionAlert) {
            Button("В настройки") {
                viewModel.openSettings()
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Чтобы получать напоминания о привычке, разрешите отправку уведомлений в настройках приложения.")
        }
    }
}

private struct DayColumnView: View {
    let config: TrackerHabitDayConfig

    let onToggleDay: () -> Void
    let onToggleNotification: () -> Void
    let onTimeChanged: (Date) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggleDay) {
                Text(config.day.abbreviationShort)
                    .font(.system(size: 14, weight: .bold))
                    .padding()
                    .background(config.isSelected ? Color.blue : Color(.systemGray5))
                    .foregroundColor(config.isSelected ? .white : .primary)
                    .cornerRadius(10)
            }

            HStack {
                Button(action: onToggleNotification) {
                    Image(systemName: config.notification.isEnabled ? "bell.fill" : "bell.slash")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(config.notification.isEnabled ? Color.orange.opacity(0.2) : Color.clear)
                        .foregroundColor(config.isSelected ? (config.notification.isEnabled ? .orange : .secondary) : .gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(config.notification.isEnabled ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                }
                .cornerRadius(10)
                .frame(width: 60)

                Spacer()

                if config.notification.isEnabled && config.isSelected {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { config.notification.time },
                            set: { onTimeChanged($0) }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .scaleEffect(0.8)
                    .frame(height: 24)
                }
            }
            .disabled(!config.isSelected)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}

#Preview {
    TrackerFormHabitScheduleView(
        viewModel: TrackerFormHabitScheduleViewModel(
            selectedDays: [.friday],
            info: .init(
                trackerId: .init(),
                isGlobalEnabled: true,
                schedule: [.friday: .init(weekDay: .friday, isEnabled: true, time: .now)]
            )
        )
    )
}
