//
//  TrackersViewControllerProtocol.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
import UIKit
protocol TrackersViewControllerProtocol {
    
    var collectionView: UICollectionView?  { get }
    
    func showStartingBlock()
    func hideStartingBlock()
}
