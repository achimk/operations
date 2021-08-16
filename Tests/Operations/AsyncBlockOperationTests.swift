import XCTest
import Operations

class AsyncBlockOperationTests: OperationTestCase {

    func test_runBlockOperation_shouldProcessCorrectly() {
        var operationInvoked = false
        let operation = AsyncBlockOperation { operationInvoked = true }

        waitFor(operation)

        XCTAssertTrue(operationInvoked)
    }

    func test_runMultipleBlocksInPipeline_shouldProcessInCorrectOrder() {

        var states: [Int] = []
        let operations = [
            AsyncBlockOperation { states.append(1) },
            AsyncBlockOperation { states.append(2) },
            AsyncBlockOperation { states.append(3) },
            AsyncBlockOperation { states.append(4) },
            AsyncBlockOperation { states.append(5) },
            AsyncBlockOperation { states.append(6) },
        ]

        pipelineDependency(for: operations)
        waitForAll(operations)

        XCTAssertEqual(states, [1, 2, 3, 4, 5, 6])
    }
}
