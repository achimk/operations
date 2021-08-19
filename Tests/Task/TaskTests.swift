import XCTest
import Operations

class TaskTests: TaskTestCase {

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
}

