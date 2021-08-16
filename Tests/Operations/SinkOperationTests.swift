import XCTest
import Foundation
import Operations

class SinkOperationTests: OperationTestCase {

    func test_successSinkOperation_shouldReturnCorrectResult() {
        let incrementOperation = SinkOperation<Int, Int, TestError> { (value, completion) -> Cancelable in
            completion(.success(value + 1))
            return Cancelables.make()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            incrementOperation.sink(value: 3)
        }

        waitFor(incrementOperation)

        XCTAssertEqual(incrementOperation.result?.value, 4)
    }

    func test_failureSinkOperation_shouldReturnCorrectResult() {
        let incrementOperation = SinkOperation<Int, Int, TestError> { (value, completion) -> Cancelable in
            completion(.failure(TestError.instance))
            return Cancelables.make()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            incrementOperation.sink(value: 3)
        }

        waitFor(incrementOperation)

        XCTAssertEqual(incrementOperation.result?.error, TestError.instance)
    }

    func test_whenSinkInvoked_operationShouldBeReady() {
        let incrementOperation = SinkOperation<Int, Int, TestError> { (value) -> Result<Int, TestError> in
            return .success(value + 1)
        }

        incrementOperation.sink(value: 1)

        XCTAssertTrue(incrementOperation.isReady)
    }

    func test_whenSinkNotInvoked_operationShouldNotBeReady() {
        let incrementOperation = SinkOperation<Int, Int, TestError> { (value) -> Result<Int, TestError> in
            return .success(value + 1)
        }

        XCTAssertFalse(incrementOperation.isReady)
    }
}