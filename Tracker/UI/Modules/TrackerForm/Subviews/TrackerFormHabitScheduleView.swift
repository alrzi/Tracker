//
//  TrackerFormHabitScheduleView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/14/26.
//

import SwiftUI

struct TrackerFormHabitScheduleView: View {
    @ObservedObject var viewModel: TrackerFormHabitScheduleViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Дни и напоминания")
                .font(.headline)

            if verticalSizeClass == .compact && !dynamicTypeSize.isAccessibilitySize {
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                    ForEach(viewModel.configs, id: \.day) { config in
                        GridRow(alignment: .center) {
                            DaySelectionButton(
                                config: config,
                                isActive: config.day == viewModel.activeDay,
                                onDayTapped: { viewModel.dayTapped(config.day) }
                            )

                            DayNotificationControlsView(
                                config: config,
                                onToggleNotification: { viewModel.toggleNotification(for: config.day) },
                                onTimeChanged: { time in viewModel.update(config.day, with: time) }
                            )
                        }
                    }
                }
            }
            else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.configs, id: \.day) { config in
                            DaySelectionButton(
                                config: config,
                                isActive: config.day == viewModel.activeDay,
                                onDayTapped: { viewModel.dayTapped(config.day) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal, -16)

                if let activeDay = viewModel.activeDay,
                   let config = viewModel.configs.first(where: { $0.day == activeDay }) {
                    ActiveDayNotificationView(
                        config: config,
                        usesVerticalLayout: dynamicTypeSize.isAccessibilitySize,
                        onToggleNotification: { viewModel.toggleNotification(for: config.day) },
                        onTimeChanged: { time in viewModel.update(config.day, with: time) }
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

private struct DayNotificationControlsView: View {
    let config: TrackerHabitDayConfig
    let onToggleNotification: () -> Void
    let onTimeChanged: (Date) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleNotification) {
                Image(systemName: config.notification.isEnabled ? "bell.fill" : "bell.slash")
                    .font(.body)
                    .padding()
                    .background(config.notification.isEnabled ? Color.orange.opacity(0.15) : Color.clear)
                    .foregroundColor(config.notification.isEnabled ? .orange : .secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if config.notification.isEnabled && config.isSelected {
                DatePicker(
                    "Время напоминания",
                    selection: Binding(
                        get: { config.notification.time },
                        set: { onTimeChanged($0) }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .datePickerStyle(.compact)
            }

            Spacer(minLength: 0)
        }
        .disabled(!config.isSelected)
        .opacity(config.isSelected ? 1 : 0.5)
    }
}

private struct DaySelectionButton: View {
    let config: TrackerHabitDayConfig
    let isActive: Bool
    let onDayTapped: () -> Void

    var body: some View {
        Button(action: onDayTapped) {
            HStack(spacing: 6) {
                Text(config.day.abbreviationShort)
                    .font(.callout.bold())

                if config.notification.isEnabled {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(config.isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(config.isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? Color.orange : Color.clear, lineWidth: 3)
                    .padding(-3)
            }
        }
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

private struct ActiveDayNotificationView: View {
    let config: TrackerHabitDayConfig
    let usesVerticalLayout: Bool
    let onToggleNotification: () -> Void
    let onTimeChanged: (Date) -> Void

    var body: some View {
        let layout = usesVerticalLayout
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        layout {
            Button(action: onToggleNotification) {
                Label(
                    config.notification.isEnabled ? "Напоминание включено" : "Добавить напоминание",
                    systemImage: config.notification.isEnabled ? "bell.fill" : "bell"
                )
                .font(.body)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(config.notification.isEnabled ? Color.orange.opacity(0.15) : Color(.systemGray5))
                .foregroundColor(config.notification.isEnabled ? .orange : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if config.notification.isEnabled && config.isSelected {
                DatePicker(
                    "Время напоминания",
                    selection: Binding(
                        get: { config.notification.time },
                        set: { onTimeChanged($0) }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .datePickerStyle(.compact)
            }

            Spacer(minLength: 0)
        }
        .disabled(!config.isSelected)
        .opacity(config.isSelected ? 1 : 0.5)
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
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
