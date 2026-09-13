import Foundation
import FoundationModels
import TrackerDomain

@available(iOS 26.0, *)
struct FoundationModelsStatisticsInsightGenerator: StatisticsInsightGenerating {
    private let model: SystemLanguageModel

    init(model: SystemLanguageModel = .default) {
        self.model = model
    }

    var isAvailable: Bool {
        get async { model.isAvailable && model.supportsLocale(Locale.current) }
    }

    func generateCopy(for candidate: StatisticsInsightCandidate) async throws -> StatisticsInsightCopy {
        let session = LanguageModelSession(
            model: model,
            instructions: """
            Write short, calm, and specific recommendations for a habit tracking app.
            Respond using the requested locale. Do not add facts absent from the input.
            Do not blame the person or promise that a change guarantees a result.
            Keep the title to six words or fewer and the explanation to two sentences or fewer.
            """
        )
        let response = try await session.respond(
            to: prompt(for: candidate),
            generating: GeneratedInsightCopy.self
        )

        return StatisticsInsightCopy(
            title: response.content.titleWords.joined(separator: " "),
            explanation: response.content.explanationSentences.joined(separator: " ")
        )
    }
}

@available(iOS 26.0, *)
private extension FoundationModelsStatisticsInsightGenerator {
    @Generable
    struct GeneratedInsightCopy {
        @Guide(description: "Words forming a short recommendation title. Each array element must contain exactly one word.")
        @Guide(.count(1...6))
        let titleWords: [String]

        @Guide(description: "Sentences explaining the recommendation using only the provided numbers. Each array element must contain exactly one complete sentence.")
        @Guide(.count(1...2))
        let explanationSentences: [String]
    }

    func prompt(for candidate: StatisticsInsightCandidate) -> String {
        """
        Habit name: \(candidate.trackerName)
        Response locale: \(Locale.current.identifier)
        Scheduled weekday with low completion: \(candidate.observedWeekDay.promptValue)
        Completed: \(candidate.completedCount) out of \(candidate.scheduledCount)
        Proposed replacement weekday: \(candidate.suggestedWeekDay.promptValue)

        Recommend moving this habit to the proposed weekday.
        """
    }
}

private extension WeekDay {
    var promptValue: String {
        switch self {
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        case .sunday: "Sunday"
        }
    }
}

struct UnavailableStatisticsInsightGenerator: StatisticsInsightGenerating {
    var isAvailable: Bool { get async { false } }

    func generateCopy(for candidate: StatisticsInsightCandidate) async throws -> StatisticsInsightCopy {
        throw CancellationError()
    }
}
