import XCTest
import Operations

class BlockOperationTests: OperationTestCase {

    func test_runBlockOperation_shouldProcessCorrectly() {
        var operationInvoked = false
        let operation = BlockOperation { operationInvoked = true }

        waitFor(operation)

        XCTAssertTrue(operationInvoked)
    }

    func test_cancelBlockOperationBeforeEnqueue_shouldNotProcess() {
        var operationInvoked = false
        let operation = BlockOperation { operationInvoked = true }

        operation.cancel()
        waitFor(operation)

        XCTAssertFalse(operationInvoked)
    }

    func test_cancelBlockOperationBeforeEnqueue_shouldCallCompletionBlock() {
        var operationInvoked = false
        var completionInvoked = false
        let operation = BlockOperation { operationInvoked = true }
        operation.addCompletionBlock {
            completionInvoked = true
        }

        operation.cancel()
        waitFor(operation)

        XCTAssertFalse(operationInvoked)
        XCTAssertTrue(completionInvoked)
    }
}
