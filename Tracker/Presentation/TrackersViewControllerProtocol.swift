import Foundation
import UIKit
protocol TrackersViewControllerProtocol: AnyObject {
    var collectionView: UICollectionView?  { get }
    func showStartingBlock()
    func hideStartingBlock()
    func showFutureDateAlert()
}
