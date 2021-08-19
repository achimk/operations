import Foundation

extension OperationQueue {

    public func addOperations(_ operations: Operation...) {
        self.addOperations(operations, waitUntilFinished: false)
    }

    public func addOperations(_ operations: [Operation]) {
        self.addOperations(operations, waitUntilFinished: false)
    }
}
