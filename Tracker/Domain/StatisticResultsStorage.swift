import Foundation

final class StatisticResultsStorage {
    static let shared = StatisticResultsStorage()
    private weak var companion: TrackersCollectionsCompanion? = nil
    private init() {}
    
    var statisticResults: [StatisticResult]? = nil
    
    func refresh() {
        print("StatisticResultsStorage refresh")
        let stats = [companion?.howManyCompletedTrackers()]
        let titles = ["Завершенные трекеры"]
        if companion?.haveStats() ?? false {
            statisticResults = []
            for (pos, res) in stats.enumerated() {
                if let validRes = res {
                    statisticResults?.append(StatisticResult(title: titles[pos], result: String(validRes)))
                }
            }
        }
        print("окончание конфигруации \(statisticResults)")
    }
    
    func configure(_ companion: TrackersCollectionsCompanion) {
        print("мне конфигурируют компаньон")
        self.companion = companion
    }
    
}
