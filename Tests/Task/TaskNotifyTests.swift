import XCTest
import Operations

class TaskNotifyTests: TaskTestCase {

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

    func test_onResultOperationPipeline_shouldNotifyInCorrectOrder() {
        var output: [Int] = []
        let task = Task(value: 1)
            .onSuccess { _ in output.append(1) }
            .onFailure { _ in output.append(0) }
            .onResult { _ in output.append(2) }
            .map { _ -> Int in throw TestError.instance }
            .onSuccess { _ in output.append(0) }
            .onFailure { _ in output.append(3) }
            .onResult { _ in output.append(4) }
            .recover { _ in 2 }
            .onSuccess { _ in output.append(5) }
            .onFailure { _ in output.append(0) }
            .onResult { _ in output.append(6) }


        let result = wait(for: task)

        XCTAssertEqual(output, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(result.output?.value, 2)
    }
}
