import XCTest
import Operations

class OperationExtensionsTests: XCTestCase {

    func test_addCompletionBlock_shouldAggreageBlocksInCorrectOrder() {
        var output: [Int] = []
        let operation = Operation()
        operation.addCompletionBlock { output.append(1) }
        operation.addCompletionBlock { output.append(2) }
        operation.addCompletionBlock { output.append(3) }

        operation.completionBlock?()

        XCTAssertEqual(output, [1, 2, 3])
    }

    func test_addDependenciesByArray_shouldContainsInCorrectOrder() {
        let operations = [
            Operation(),
            Operation(),
            Operation()
        ]
        let operation = Operation()

        operation.addDependencies(operations)

        XCTAssertEqual(operation.dependencies, operations)
    }

    func test_addDependenciesByArrayLiteral_shouldContainsInCorrectOrder() {
        let operations = [
            Operation(),
            Operation(),
            Operation()
        ]
        let operation = Operation()

        operation.addDependencies(operations[0], operations[1], operations[2])

        XCTAssertEqual(operation.dependencies, operations)
    }
}
