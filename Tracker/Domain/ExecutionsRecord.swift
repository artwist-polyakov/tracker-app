import Foundation

protocol ExecutionsRecord {
    var date: SimpleDate { get }
    var trackerId: UUID { get }
}

struct ExecutionsRecordImpl: ExecutionsRecord {
    let date: SimpleDate
    let trackerId: UUID
}
