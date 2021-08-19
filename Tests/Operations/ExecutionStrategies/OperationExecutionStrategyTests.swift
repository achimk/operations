import XCTest
import Operations

class OperationExecutionStrategyTests: XCTestCase {

    func test_alwaysAllowedStrategy_shouldAlwaysPass() {
        let strategy = OperationExecutionStrategy.alwaysAllowed
        let result = strategy.canExecute(operation: Operation())
        XCTAssertTrue(result)
    }

    func test_alwaysDeniedStrategy_shouldNeverPass() {
        let strategy = OperationExecutionStrategy.alwaysDenied
        let result = strategy.canExecute(operation: Operation())
        XCTAssertFalse(result)
    }

    func test_shouldNotCanceledStrategy_shouldPassWhenNotCanceled() {
        let notCanceledOperation = Operation()
        let strategy = OperationExecutionStrategy.isNotCanceled
        let result = strategy.canExecute(operation: notCanceledOperation)
        XCTAssertTrue(result)
    }

    func test_shouldNotCanceledStrategy_shouldNotPassWhenCanceled() {
        let canceledOperation = Operation()
        canceledOperation.cancel()
        let strategy = OperationExecutionStrategy.isNotCanceled
        let result = strategy.canExecute(operation: canceledOperation)
        XCTAssertFalse(result)
    }

    func test_shouldNotCanceledDependenciesStrategy_shouldPassWhenDependenciesAreNotCanceled() {

        let notCanceledOperation = Operation()
        let operation = Operation()
        operation.addDependency(notCanceledOperation)
        let strategy = OperationExecutionStrategy.hasNotCanceledDependencies
        let result = strategy.canExecute(operation: operation)
        XCTAssertTrue(result)
    }

    func test_shouldNotCanceledDependenciesStrategy_shouldNotPassWhenDependenciesAreCanceled() {

        let canceledOperation = Operation()
        canceledOperation.cancel()
        let operation = Operation()
        operation.addDependency(canceledOperation)
        let strategy = OperationExecutionStrategy.hasNotCanceledDependencies
        let result = strategy.canExecute(operation: operation)
        XCTAssertFalse(result)
    }

    func test_andOperation_shouldProduceValidResult() {
        let strategy = OperationExecutionStrategy.alwaysAllowed.and(.alwaysDenied)
        let result = strategy.canExecute(operation: Operation())
        XCTAssertFalse(result)
    }

    func test_orOperation_shouldProduceValidResult() {
        let strategy = OperationExecutionStrategy.alwaysAllowed.or(.alwaysDenied)
        let result = strategy.canExecute(operation: Operation())
        XCTAssertTrue(result)
    }

    func test_notOperation_shouldProduceValidResult() {
        let strategy = OperationExecutionStrategy.alwaysDenied.not()
        let result = strategy.canExecute(operation: Operation())
        XCTAssertTrue(result)
    }
}
