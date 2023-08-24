struct AlertModel {
    var title: String
    var message: String
    var primaryButtonText: String
    var primaryButtonCompletion: (() -> ())
    var secondaryButtonText: String?
    var secondaryButtonCompletion: (() -> ())?
}
