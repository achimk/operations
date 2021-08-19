import Foundation

open class OperationExecutionStrategy {

    public init() { }

    open func canExecute(operation: Operation) -> Bool {
        abstractMethod()
    }

    public func asExecutionStrategy() -> OperationExecutionStrategy {
        return self
    }
}

extension OperationExecutionStrategy {

    public static let alwaysAllowed: OperationExecutionStrategy = {
        return ConditionExecutionStrategy { _ in return true }
    }()

    public static let alwaysDenied: OperationExecutionStrategy = {
        return ConditionExecutionStrategy { _ in return false }
    }()

    public static let isNotCanceled: OperationExecutionStrategy = {
        return ConditionExecutionStrategy { return !$0.isCancelled }
    }()

    public static let hasNotCanceledDependencies: OperationExecutionStrategy = {
        return ConditionExecutionStrategy { return !$0.hasCanceledDependencies() }
    }()
}

extension OperationExecutionStrategy {

    public func and(_ other: OperationExecutionStrategy) -> OperationExecutionStrategy {
        return ConditionExecutionStrategy { self.canExecute(operation: $0) && other.canExecute(operation: $0) }
    }

    public func or(_ other: OperationExecutionStrategy) -> OperationExecutionStrategy {
        return ConditionExecutionStrategy { self.canExecute(operation: $0) || other.canExecute(operation: $0) }
    }

    public func not() -> OperationExecutionStrategy {
        return ConditionExecutionStrategy { !self.canExecute(operation: $0) }
    }
}
