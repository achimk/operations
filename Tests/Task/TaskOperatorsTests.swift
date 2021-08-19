import XCTest
import Operations

class TaskOperatorsTests: TaskTestCase {

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
}
