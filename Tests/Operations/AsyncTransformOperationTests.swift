import XCTest
import Foundation
import Operations

class AsyncTransformOperationTests: OperationTestCase {

    func test_successAsyncTransformOperation_shouldReturnCorrectResult() {
        let incrementOperation = AsyncTransformOperation<Int, Int> { (value, completion) -> Cancelable in
            completion(.success(value + 1))
            return Cancelables.make()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            incrementOperation.sink(value: 3)
        }

        waitFor(incrementOperation)

        XCTAssertEqual(incrementOperation.result?.value, 4)
    }

    func test_failureAsyncTransformOperation_shouldReturnCorrectResult() {
        let incrementOperation = AsyncTransformOperation<Int, Int> { (value, completion) -> Cancelable in
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
        let incrementOperation = AsyncTransformOperation<Int, Int> { (value) -> Result<Int, Error> in
            return .success(value + 1)
        }

        incrementOperation.sink(value: 1)

        XCTAssertTrue(incrementOperation.isReady)
    }

    func test_whenSinkNotInvoked_operationShouldNotBeReady() {
        let incrementOperation = AsyncTransformOperation<Int, Int> { (value) -> Result<Int, Error> in
            return .success(value + 1)
        }

        XCTAssertFalse(incrementOperation.isReady)
    }
}
