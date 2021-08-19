import XCTest
import Foundation
import Operations

class TaskTestCase: XCTestCase {

    @discardableResult
    func enqueue<T>(_ task: Task<T>) -> (run: () -> (), expectation: XCTestExpectation, output: () -> Result<T, Error>?, cancel: () -> ()) {
        let mutableBox = MutableBox<Result<T, Error>?>(nil)
        let expectation = self.expectation(description: "finish")
        let queue = OperationQueue()
        queue.isSuspended = true
        let cancelToken = task.run(on: queue) { result in
            mutableBox.set(value: result)
            expectation.fulfill()
        }

        return ({ queue.isSuspended = false }, expectation, mutableBox.getValue, cancelToken.cancel)
    }

    @discardableResult
    func run<T>(_ task: Task<T>) -> (expectation: XCTestExpectation, output: () -> Result<T, Error>?, cancel: () -> ()) {
        let mutableBox = MutableBox<Result<T, Error>?>(nil)
        let expectation = self.expectation(description: "finish")
        let cancelToken = task.run { result in
            mutableBox.set(value: result)
            expectation.fulfill()
        }

        return (expectation, mutableBox.getValue, cancelToken.cancel)
    }

    @discardableResult
    func wait<T>(for task: Task<T>, timeout seconds: TimeInterval = 3) -> (output: Result<T, Error>?, cancel: () -> ()) {
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
