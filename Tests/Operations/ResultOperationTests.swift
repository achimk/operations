import XCTest
@testable import Operations

class ResultOperationTests: OperationTestCase {

    func test_successResultOperation_shouldReturnCorrectResult() {
        let operation = ResultOperation<Int> { (completion) -> Cancelable in
            completion(.success(1))
            return Cancelables.make()
        }

        waitFor(operation)

        XCTAssertEqual(operation.result?.value, 1)
    }

    func test_failureResultOperation_shouldReturnCorrectResult() {
        let operation = ResultOperation<Int> { (completion) -> Cancelable in
            completion(.failure(TestError.instance))
            return Cancelables.make()
        }

        waitFor(operation)

        XCTAssertTrue(operation.result?.error is TestError)
    }

    func test_cancelResultOperationBeforeEnqueue_shouldReturnCancelError() {
        let operation = ResultOperation<Int> { (completion) -> Cancelable in
            completion(.success(1))
            return Cancelables.make()
        }

        operation.cancel()

        waitFor(operation)

        XCTAssertTrue(operation.result?.error is OperationCanceledError)
    }

    func test_cancelResultOperationDuringRun_shouldReturnDesignatedError() {
        let operation = SpyResultOperation<Int> { (completion) -> Cancelable in
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
