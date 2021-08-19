import XCTest
import Operations

class TaskTests: TaskTestCase {

    func test_createSuccessTask_shouldProcessCorrectly() {
        let task = Task(value: 1)
        let result = wait(for: task)
        XCTAssertEqual(result.output?.value, 1)
    }

    func test_createFailureTask_shouldProcessCorrectly() {
        let task = Task<Int>(error: TestError.instance)
        let result = wait(for: task)
        XCTAssertTrue(result.output?.error as? TestError != nil)
    }

    func test_createAndRunTask_shouldMatchOperationsCount() {
        let queue = MockOperationQueue()
        let task = Task(value: 1)

        task.run(on: queue)

        XCTAssertEqual(queue.operations.count, 1)
    }

    func test_createThenMapAndRunTask_shouldMatchOperationsCount() {
        let queue = MockOperationQueue()
        let task = Task(value: 1).map { String($0) }

        task.run(on: queue)

        XCTAssertEqual(queue.operations.count, 2)
    }

    func test_createThenBindAndRunTask_shouldMatchOperationsCount() {
        let queue = MockOperationQueue()
        let task = Task(value: 1).bind { (value: Int, completion: Completer<String>) -> Cancelable in
            completion(.success(String(value)))
            return Cancelables.make()
        }

        task.run(on: queue)

        XCTAssertEqual(queue.operations.count, 2)
    }

    func test_createThenRecoverAndRunTask_shouldMatchOperationsCount() {
        let queue = MockOperationQueue()
        let task = Task<Int>(error: TestError.instance).recover { _ in 1 }

        task.run(on: queue)

        XCTAssertEqual(queue.operations.count, 2)
    }

    func test_createThenNotifyAndRunTask_shouldMatchOperationsCount() {
        let queue = MockOperationQueue()
        let task = Task(value: 1)
            .onSuccess { _ in }
            .onFailure { _ in }
            .onResult { _ in }

        task.run(on: queue)

        XCTAssertEqual(queue.operations.count, 1)
    }
}

