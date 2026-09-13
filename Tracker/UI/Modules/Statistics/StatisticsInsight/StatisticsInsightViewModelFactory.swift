import Foundation
import TrackerDomain

final class StatisticsInsightViewModelFactory {
    private let generateUseCase: any GenerateStatisticsInsightUseCaseProtocol
    private let applyUseCase: any ApplyStatisticsInsightUseCaseProtocol

    init(
        generateUseCase: some GenerateStatisticsInsightUseCaseProtocol,
        applyUseCase: some ApplyStatisticsInsightUseCaseProtocol
    ) {
        self.generateUseCase = generateUseCase
        self.applyUseCase = applyUseCase
    }

    @MainActor
    func makeViewModel() -> StatisticsInsightViewModel {
        StatisticsInsightViewModel(
            generateUseCase: generateUseCase,
            applyUseCase: applyUseCase
        )
    }
}
