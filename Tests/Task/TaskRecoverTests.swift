import XCTest
import Operations

class TaskRecoverTests: TaskTestCase {

    struct OtherTestError: Error { }

    func test_recoverFailureOperation_shouldProcessCorrectly() {
        let task = Task<Int>(error: TestError.instance).recover { error -> Int in
            return 1
        }

        let result = wait(for: task)

        XCTAssertEqual(result.output?.value, 1)
    }

    func test_asyncRecoverFailureOperation_shouldProcessCorrectly() {
        let task = Task<Int>(error: TestError.instance).recover { (error, completion) -> Cancelable in
            completion(.success(1))
            return Cancelables.make()
        }

        let result = wait(for: task)

        XCTAssertEqual(result.output?.value, 1)
    }

    func test_failureRecoverFailureOperation_shouldPropagateError() {
        let task = Task<Int>(error: TestError.instance).recover { error -> Int in
            throw OtherTestError()
        }

        let result = wait(for: task)

        XCTAssertTrue(result.output?.error is OtherTestError)
    }

    func test_failureAsyncRecoverFailureOperation_shouldPropagateError() {
        let task = Task<Int>(error: TestError.instance).recover { (error, completion) -> Cancelable in
            completion(.failure(OtherTestError()))
            return Cancelables.make()
        }

        let result = wait(for: task)

        XCTAssertTrue(result.output?.error is OtherTestError)
    }
}
