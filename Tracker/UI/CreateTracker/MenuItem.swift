import Foundation

struct MenuItem {
    let title: String
    var subtitle: String
    let action: () -> Void
}
