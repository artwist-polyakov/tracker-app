import Foundation
import UIKit
protocol TrackersViewControllerProtocol: AnyObject {
    var collectionView: UICollectionView?  { get }
    func showStartingBlock()
    func hideStartingBlock()
    func showFutureDateAlert()
    func updateStartingBlockState (_ state: PRESENTER_ERRORS)
}
