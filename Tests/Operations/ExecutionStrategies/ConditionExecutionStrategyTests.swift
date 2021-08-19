import XCTest
import Operations

class ConditionExecutionStrategyTests: XCTestCase {

    func test_validCondtion_shouldReturnValidValue() {
        let strategy = ConditionExecutionStrategy { _ in return true }
        let result = strategy.canExecute(operation: Operation())
        XCTAssertTrue(result)
    }

    func test_invalidCondtion_shouldReturnInvalidValue() {
        let strategy = ConditionExecutionStrategy { _ in return false }
        let result = strategy.canExecute(operation: Operation())
        XCTAssertFalse(result)
    }
}
