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

        XCTAssertEqual(result.output?.isFailure, true)
        XCTAssertTrue((result.output?.error as? TestError) != nil)
    }

    func test_runCancelTaskInPipeline_shouldReportCancelError() {
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

        let result = run(task)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            result.cancel()
        }

//        result.cancel()

        wait(for: [result.expectation], timeout: 8)

        print(result.output())
        XCTAssertEqual(result.output()?.isFailure, true)
    }
}
