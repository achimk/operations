import XCTest
import Operations

class OperationQueueExtensionsTests: XCTestCase {

    func test_addOperationsByArray_shouldAddInCorrectOrder() {
        let operations = [
            Operation(),
            Operation(),
            Operation()
        ]
        let queue = MockOperationQueue()

        queue.addOperations(operations)

        XCTAssertEqual(queue.operations, operations)
    }

    func test_addOperationsByArrayLiteral_shouldAddInCorrectOrder() {
        let operations = [
            Operation(),
            Operation(),
            Operation()
        ]
        let queue = MockOperationQueue()

        queue.addOperations(operations[0], operations[1], operations[2])

        XCTAssertEqual(queue.operations, operations)
    }
}
