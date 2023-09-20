import Foundation

final class StatisticResultsStorage {
    static let shared = StatisticResultsStorage()
    private weak var companion: TrackersCollectionsCompanion? = nil
    private init() {}
    
    var statisticResults: [StatisticResult]? = nil
    
    func refresh(_ completion: (() -> Void)? = nil) {
        let stats = [companion?.howManyCompletedTrackers(), companion?.mostLongSeries()]
        let titles = [L10n.Stats.completedTrackers, L10n.Stats.completedTrackers]
        if companion?.haveStats() ?? false {
            statisticResults = []
            for (pos, res) in stats.enumerated() {
                if let validRes = res {
                    statisticResults?.append(StatisticResult(title: titles[pos], result: String(validRes)))
                }
            }
        } else {
            statisticResults = []
        }
        guard let completion = completion else { return }
        completion()
    }
    
    func configure(_ companion: TrackersCollectionsCompanion) {
        self.companion = companion
    }
    
}
