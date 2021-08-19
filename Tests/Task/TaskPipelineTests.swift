import XCTest
import Operations

class TaskPipelineTests: TaskTestCase {

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

    func test_runFailureTaskInPipeline_shouldReportError() {
        let asyncGetValue: (Void, Completer<Int>) -> Cancelable = { (_, completion) in
            completion(.failure(TestError.instance))
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

        XCTAssertTrue(result.output?.error is TestError)
    }

    func test_cancelTaskInPipelineBeforeRun_shouldReportCancelOperationError() {
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

        let result = enqueue(task)
        result.cancel()
        result.run()

        wait(for: [result.expectation], timeout: 3)

        XCTAssertTrue(result.output()?.error is OperationCanceledError)
    }

    func test_cancelTaskInPipelineAfterRun_shouldReportCancelableError() {
        let asyncGetValue: (Void, @escaping Completer<Int>) -> Cancelable = { (_, completion) in
            return Cancelables.make {
                completion(.failure(TestError.instance))
            }
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

        let result = enqueue(task)
        result.cancel()
        result.run()

        wait(for: [result.expectation], timeout: 3)

        XCTAssertTrue(result.output()?.error is OperationCanceledError)
    }

}
