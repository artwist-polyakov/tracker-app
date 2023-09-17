import Foundation
import UIKit
protocol TrackersViewControllerProtocol: AnyObject {
    var collectionView: UICollectionView?  { get }
    func showStartingBlock()
    func hideStartingBlock()
    func showFutureDateAlert()
    func updateStartingBlockState (_ state: PRESENTER_ERRORS)
    func showDeleteConfirmation(_ completion: @escaping  ()->())
    func launchEditProcess (tracker: Tracker, days: Int)
}
