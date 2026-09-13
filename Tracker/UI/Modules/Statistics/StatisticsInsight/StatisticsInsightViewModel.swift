import Foundation
import TrackerDomain

@MainActor
final class StatisticsInsightViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case content(Content)
        case hidden
    }

    struct Content: Equatable {
        enum ActionState: Equatable {
            case idle
            case applying
            case succeeded
            case failed
        }

        let trackerID: UUID
        let trackerName: String
        let title: String
        let explanation: String
        let completedCount: Int
        let scheduledCount: Int
        let observedWeekDay: String
        let suggestedWeekDay: String
        var actionState: ActionState
    }

    private let generateUseCase: any GenerateStatisticsInsightUseCaseProtocol
    private let applyUseCase: any ApplyStatisticsInsightUseCaseProtocol
    private var loadTask: Task<Void, Never>?
    private var applyTask: Task<Void, Never>?
    private var insight: StatisticsInsight?
    private var generation = 0

    @Published private(set) var state: ViewState = .idle

    init(
        generateUseCase: some GenerateStatisticsInsightUseCaseProtocol,
        applyUseCase: some ApplyStatisticsInsightUseCaseProtocol
    ) {
        self.generateUseCase = generateUseCase
        self.applyUseCase = applyUseCase
    }

    func screenAppeared() {
        guard case .idle = state else { return }

        generation += 1
        let currentGeneration = generation
        let useCase = generateUseCase
        state = .loading

        loadTask = Task { [weak self] in
            do {
                let insight = try await useCase.execute()
                guard !Task.isCancelled, self?.generation == currentGeneration else { return }
                self?.insight = insight
                self?.state = insight.map(Self.makeContent) ?? .hidden
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled, self?.generation == currentGeneration else { return }
                self?.state = .hidden
            }
        }
    }

    func screenDisappeared() {
        loadTask?.cancel()
        applyTask?.cancel()
        loadTask = nil
        applyTask = nil
        insight = nil
        generation += 1
        state = .idle
    }

    func applyScheduleChangeTapped() {
        guard case .content(var content) = state,
              content.actionState != .applying,
              content.actionState != .succeeded,
              let insight
        else {
            return
        }

        content.actionState = .applying
        state = .content(content)
        let applyUseCase = applyUseCase

        applyTask = Task { [weak self] in
            do {
                try await applyUseCase.execute(insight)
                guard !Task.isCancelled, var updatedContent = self?.content else { return }
                updatedContent.actionState = .succeeded
                self?.state = .content(updatedContent)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled, var updatedContent = self?.content else { return }
                updatedContent.actionState = .failed
                self?.state = .content(updatedContent)
            }
        }
    }

    func refreshRequested() {
        loadTask?.cancel()
        applyTask?.cancel()
        loadTask = nil
        applyTask = nil
        insight = nil
        generation += 1
        state = .idle
        screenAppeared()
    }

    deinit {
        loadTask?.cancel()
        applyTask?.cancel()
    }
}

private extension StatisticsInsightViewModel {
    var content: Content? {
        guard case .content(let content) = state else { return nil }
        return content
    }

    static func makeContent(from insight: StatisticsInsight) -> ViewState {
        let suggestedWeekDay: WeekDay
        switch insight.proposedAction {
        case .moveSchedule(_, let destination):
            suggestedWeekDay = destination
        }

        return .content(
            Content(
                trackerID: insight.trackerID,
                trackerName: insight.trackerName,
                title: insight.title,
                explanation: insight.explanation,
                completedCount: insight.evidence.completedCount,
                scheduledCount: insight.evidence.scheduledCount,
                observedWeekDay: insight.evidence.observedWeekDay.abbreviationLong,
                suggestedWeekDay: suggestedWeekDay.abbreviationLong,
                actionState: .idle
            )
        )
    }
}
