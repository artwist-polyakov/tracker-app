import Foundation

protocol TrackersCollectionsCompanionDelegate: AnyObject {
    func handleFunctionButtonTapped(at indexPath: Int, inSection section: Int,  date: Date, text: String)
    func quantityTernar(_ quantity: Int)
    func setInteractor(interactor: TrackersCollectionsCompanionInteractor)
}
