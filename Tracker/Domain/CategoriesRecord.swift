import Foundation

protocol CategoriesRecord {
    var id: UUID { get }
    var creationDate: Date { get }
    var title: String { get }
    
}

struct CategoriesRecordImpl: CategoriesRecord {
    let id: UUID
    let creationDate: Date
    let title: String
}
