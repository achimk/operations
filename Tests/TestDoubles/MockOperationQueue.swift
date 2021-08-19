import Foundation

class MockOperationQueue: OperationQueue {

    override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        isSuspended = true
        super.addOperations(ops, waitUntilFinished: wait)
    }

    func runEnqueuedOperations() {
        isSuspended = false
    }
}
