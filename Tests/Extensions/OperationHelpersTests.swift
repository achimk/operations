import XCTest
import Foundation
import Operations

class OperationHelpersTests: XCTestCase {

    func test_pipelineDependencyFunction_shouldRunOperationsInCorrectOrder() {
        var states: [Int] = []
        let operations = [
            BlockOperation { states.append(1) },
            BlockOperation { states.append(2) },
            BlockOperation { states.append(3) },
            BlockOperation { states.append(4) },
            BlockOperation { states.append(5) },
            BlockOperation { states.append(6) }
        ]

        pipelineDependency(for: operations)

        let queue = OperationQueue()
        queue.addOperations(operations, waitUntilFinished: true)

        XCTAssertEqual(states, [1, 2, 3, 4, 5, 6])
    }

    func test_onFinishFunction_shouldNotifyWhenAllOperationsFinished() {
        let operations = [
            BlockOperation { },
            BlockOperation { },
            BlockOperation { }
        ]

        let expectation = self.expectation(description: "Finish")
        onFinish(operations) {
            expectation.fulfill()
        }

        let queue = OperationQueue()
        queue.addOperations(operations, waitUntilFinished: false)
        wait(for: [expectation], timeout: 1)

        operations.forEach { (operation) in
            XCTAssertTrue(operation.isFinished)
        }
    }

    func test_finishOperationFunction_shouldNotifyWhenAllOperationsFinished() {
        let operations = [
            BlockOperation { },
            BlockOperation { },
            BlockOperation { }
        ]

        let expectation = self.expectation(description: "Finish")
        let done = finishOpration(operations) {
            expectation.fulfill()
        }

        let queue = OperationQueue()
        queue.addOperations(operations + [done], waitUntilFinished: false)
        wait(for: [expectation], timeout: 1)

        operations.forEach { (operation) in
            XCTAssertTrue(operation.isFinished)
        }
    }
}
