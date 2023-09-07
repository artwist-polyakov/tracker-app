import Foundation
protocol CategorySelectionViewModelDelegate {
    func setNavigationState(state: categoriesNavigationState)
    func refreshState()
}
