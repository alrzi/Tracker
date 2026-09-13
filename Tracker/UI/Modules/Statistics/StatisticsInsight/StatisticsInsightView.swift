import SwiftUI

struct StatisticsInsightView: View {
    @ObservedObject var viewModel: StatisticsInsightViewModel

    var body: some View {
        if case .content(let content) = viewModel.state {
            StatisticsInsightContentView(
                content: content,
                onApply: viewModel.applyScheduleChangeTapped
            )
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

private struct StatisticsInsightContentView: View {
    let content: StatisticsInsightViewModel.Content
    let onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.purple)
                    .frame(width: 38, height: 38)
                    .background(.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("AI analysis")
                        .font(.caption)
                        .foregroundStyle(.purple)

                    Text(content.title)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(content.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(content.trackerName): \(content.observedWeekDay) → \(content.suggestedWeekDay)")
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                EvidenceView(
                    title: content.observedWeekDay,
                    value: "\(content.completedCount)/\(content.scheduledCount)",
                    color: .red
                )

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                EvidenceView(
                    title: content.suggestedWeekDay,
                    value: String(localized: "Try this day"),
                    color: .green
                )
            }

            ScheduleActionView(state: content.actionState, onApply: onApply)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.purple.opacity(0.35), lineWidth: 1)
        }
    }
}

private struct ScheduleActionView: View {
    let state: StatisticsInsightViewModel.Content.ActionState
    let onApply: () -> Void

    var body: some View {
        HStack {
            Spacer()

            switch state {
            case .idle:
                Button("Изменить день", action: onApply)
                    .buttonStyle(.borderedProminent)

            case .applying:
                ProgressView()
                    .controlSize(.small)

            case .succeeded:
                Label("День изменён", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)

            case .failed:
                Button("Повторить изменение", action: onApply)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

private struct EvidenceView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 11))
    }
}
