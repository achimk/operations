import XCTest
@testable import Operations

class AsyncResultOperationTests: OperationTestCase {

    func test_successAsyncResultOperation_shouldReturnCorrectResult() {
        let operation = AsyncResultOperation<Int> { (completion) -> Cancelable in
            completion(.success(1))
            return Cancelables.make()
        }

        waitFor(operation)

        XCTAssertEqual(operation.result?.value, 1)
    }

    func test_failureAsyncResultOperation_shouldReturnCorrectResult() {
        let operation = AsyncResultOperation<Int> { (completion) -> Cancelable in
            completion(.failure(TestError.instance))
            return Cancelables.make()
        }

        waitFor(operation)

        XCTAssertTrue(operation.result?.error is TestError)
    }

    func test_cancelAsyncResultOperationBeforeEnqueue_shouldReturnCancelError() {
        let operation = AsyncResultOperation<Int> { (completion) -> Cancelable in
            completion(.success(1))
            return Cancelables.make()
        }

        operation.cancel()

        waitFor(operation)

        XCTAssertTrue(operation.result?.error is OperationCanceledError)
    }

    func test_cancelAsyncResultOperationDuringRun_shouldReturnDesignatedError() {
        let operation = SpyAsyncResultOperation<Int> { (completion) -> Cancelable in
            return Cancelables.make {
                completion(.failure(TestError.instance))
            }
        }

        operation.onPostExecute = { op in
            op.cancel()
        }

        waitFor(operation)

        XCTAssertTrue(operation.result?.error is TestError)
    }
}
