import XCTest
import Operations

class TaskBenchmarkTests: TaskTestCase {

    // Run only for debug to discover invalid state changes over Operation implementation
    func test_multipeCalls_shouldPassAll() {
        for _ in 0..<1000 {
            assert_runAsyncTasksInPipeline_shouldProduceCorrectResult()
        }
    }

    func assert_runAsyncTasksInPipeline_shouldProduceCorrectResult() {
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
            .onSuccess { _ in }
            .onFailure { _ in }
            .onResult { _ in }
            .map { _ in () }
            .recover { _ in () }
            .bind(asyncGetValue)
            .onSuccess { _ in }
            .onFailure { _ in }
            .onResult { _ in }
            .map { $0 }
            .recover { _ in 1 }
            .bind(asyncIncrementValue)
            .onSuccess { _ in }
            .onFailure { _ in }
            .onResult { _ in }
            .map { $0 }
            .recover { _ in 1 }
            .bind(asyncMapValue)
            .onSuccess { _ in }
            .onFailure { _ in }
            .onResult { _ in }
            .map { $0 }
            .recover { _ in "1" }

        let result = wait(for: task)

        XCTAssertEqual(result.output?.value, "2")
    }
}
