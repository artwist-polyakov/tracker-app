import Foundation

struct MenuItem {
    var title: String
    var subtitle: String
    let action: () -> Void
}
