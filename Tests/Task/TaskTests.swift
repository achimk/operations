import XCTest
import Foundation
import Operations

class TaskTests: XCTestCase {

    // MARK: - Create

    func test_createSuccessOperation_shouldProcessCorrectly() {
        let task = Task(value: 1)
        let result = wait(for: task)
        XCTAssertEqual(result.output?.value, 1)
    }

    func test_createFailureOperation_shouldProcessCorrectly() {
        let task = Task<Int>(error: TestError.instance)
        let result = wait(for: task)
        XCTAssertTrue(result.output?.error as? TestError != nil)
    }

    func test_sinkSuccessOperation_shouldProcessCorretly() {
        let task = Task.sink { (completion: Completer<Int>) -> Cancelable in
            completion(.success(1))
            return Cancelables.make()
        }

        let result = wait(for: task)

        XCTAssertEqual(result.output?.value, 1)
    }

    // MARK: - Operations

    func test_bindSuccessOperation_shouldProcessCorrectly() {
        let task = Task(value: 3).bind { (value: Int, completion: Completer<Int>) -> Cancelable in
            completion(.success(value + 1))
            return Cancelables.make()
        }

        let result = wait(for: task)

        XCTAssertEqual(result.output?.value, 4)
    }

    func test_mapSuccessOperation_shouldProcessCorrectly() {
        let task = Task(value: 1).map { (value) -> String in
            return String(value)
        }

        let result = wait(for: task)

        XCTAssertEqual(result.output?.value, "1")
    }

    // MARK: - Notify

    func test_onSuccessOperation_shouldNotifyCorrectly() {
        var result: Int?
        let task = Task(value: 1).onSuccess { (value) in
            result = value
        }

        wait(for: task)

        XCTAssertEqual(result, 1)
    }

    func test_onFailureOperation_shouldNotifyCorrectly() {
        var result: Error?
        let task = Task<Int>(error: TestError.instance).onFailure { (error) in
            result = error
        }

        wait(for: task)

        XCTAssertNotNil(result as? TestError)
    }

    func test_onResultOperation_shouldNotifyCorrectly() {
        var result: Result<Int, Error>?
        let task = Task(value: 1).onResult { (res) in
            result = res
        }

        wait(for: task)

        XCTAssertEqual(result?.value, 1)
    }

    // MARK: - Pipeline

    func test_runAsyncTasksInPipeline_shouldProduceCorrectResult() {
        let asyncGetValue: (Void, Completer<Int>) -> Cancelable = { (_, completion) in
            completion(.success(1))
            return Cancelables.make()
        }

        let asyncIncrementValue: (Int, Completer<Int>) -> Cancelable = { (value, completion) in
            completion(.success(value + 1))
            return Cancelables.make()
        }

        let asyncMapValue: (Int, Completer<String>) -> Cancelable = { (value, completion) in
            completion(.success(String(value)))
            return Cancelables.make()
        }

        let task = Task.create()
            .bind(asyncGetValue)
            .bind(asyncIncrementValue)
            .bind(asyncMapValue)

        let result = wait(for: task)

        XCTAssertEqual(result.output?.value, "2")
    }

    // MARK: - Benchmarks

    // Run only for debug to discover invalid state changes over Operation implementation
    func test_multipeCalls_shouldPassAll() {
        for index in 0..<1000 {
            print("=> run: \(index)")
            test_runAsyncTasksInPipeline_shouldProduceCorrectResult()
        }
    }

    // MARK: Private

    @discardableResult
    private func wait<T>(for task: Task<T>, timeout seconds: TimeInterval = 3) -> (output: Result<T, Error>?, cancel: () -> ()) {
        var output: Result<T, Error>?
        let expectation = self.expectation(description: "finish")
        let cancelToken = task.run { result in
            output = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: seconds)

        return (output, cancelToken.cancel)
    }
}

