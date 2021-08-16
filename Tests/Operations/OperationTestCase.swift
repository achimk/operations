import XCTest
import Operations

class OperationTestCase: XCTestCase {

    private(set) var queue = OperationQueue()

    override func setUp() {
        queue = OperationQueue()
        super.setUp()
    }

    override func tearDown() {
        queue.cancelAllOperations()
        super.tearDown()
    }

    func waitFor(_ operation: Foundation.Operation, timeout seconds: TimeInterval = 1) {
        let doneExpectation = expectation(description: "Done")
        let doneOperation = BlockOperation { doneExpectation.fulfill() }
        doneOperation.addDependency(operation)
        queue.addOperations([operation, doneOperation], waitUntilFinished: false)
        wait(for: [doneExpectation], timeout: seconds)
    }

    func waitForAll(_ operations: [Foundation.Operation], timeout seconds: TimeInterval = 1) {
        let doneExpectation = expectation(description: "Done")
        queue.addOperations(operations, waitUntilFinished: false)
        onFinish(operations) { doneExpectation.fulfill() }
        wait(for: [doneExpectation], timeout: seconds)
    }
}

