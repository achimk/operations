import Foundation
import Operations

class CancelTokenObserver: NSObject {

    private let operation: Operation

    var onCancelTokenChange: (() -> ())?

    init(operation: Operation) {
        self.operation = operation
        super.init()
        operation.addObserver(self, forKeyPath: "cancelToken", options: [], context: nil)
    }

    deinit {
        operation.removeObserver(self, forKeyPath: "cancelToken")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "cancelToken" else { return }
        onCancelTokenChange?()
    }
}
