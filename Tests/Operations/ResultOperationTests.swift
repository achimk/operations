import XCTest
import Operations

class ResultOperationTests: OperationTestCase {

    func test_successResultOperation_shouldReturnCorrectResult() {
        let operation = ResultOperation<Int, TestError> { (completion) -> Cancelable in
            completion(.success(1))
            return Cancelables.make()
        }

        waitFor(operation)

        XCTAssertEqual(operation.result?.value, 1)
    }

    func test_failureResultOperation_shouldReturnCorrectResult() {
        let operation = ResultOperation<Int, TestError> { (completion) -> Cancelable in
            completion(.failure(TestError.instance))
            return Cancelables.make()
        }

        waitFor(operation)

        XCTAssertEqual(operation.result?.error, TestError.instance)
    }
}
