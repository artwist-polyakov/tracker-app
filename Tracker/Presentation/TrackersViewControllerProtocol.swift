import Foundation
import UIKit
protocol TrackersViewControllerProtocol {
    var collectionView: UICollectionView?  { get }
    func showStartingBlock()
    func hideStartingBlock()
    func showFutureDateAlert()
}
