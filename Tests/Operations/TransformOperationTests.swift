import XCTest
import Foundation
import Operations

class TransformOperationTests: OperationTestCase {

    func test_successTransformOperation_shouldReturnCorrectResult() {
        let incrementOperation = TransformOperation<Int, Int> { (value, completion) -> Cancelable in
            completion(.success(value + 1))
            return Cancelables.make()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            incrementOperation.sink(value: 3)
        }

        waitFor(incrementOperation)

        XCTAssertEqual(incrementOperation.result?.value, 4)
    }

    func test_failureTransformOperation_shouldReturnCorrectResult() {
        let incrementOperation = TransformOperation<Int, Int> { (value, completion) -> Cancelable in
            completion(.failure(TestError.instance))
            return Cancelables.make()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            incrementOperation.sink(value: 3)
        }

        waitFor(incrementOperation)

        XCTAssertTrue(incrementOperation.result?.error is TestError)
    }

    func test_whenSinkInvoked_operationShouldBeReady() {
        let incrementOperation = TransformOperation<Int, Int> { (value) -> Result<Int, Error> in
            return .success(value + 1)
        }

        incrementOperation.sink(value: 1)

        XCTAssertTrue(incrementOperation.isReady)
    }

    func test_whenSinkNotInvoked_operationShouldNotBeReady() {
        let incrementOperation = TransformOperation<Int, Int> { (value) -> Result<Int, Error> in
            return .success(value + 1)
        }

        XCTAssertFalse(incrementOperation.isReady)
    }
}
