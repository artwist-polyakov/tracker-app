import Foundation

protocol TrackersCollectionsCompanionDelegate: AnyObject {
    func quantityTernar(_ quantity: Int)
    func setInteractor(interactor: TrackersCollectionsCompanionInteractor)
}
