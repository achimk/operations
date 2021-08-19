import Foundation

public final class ConditionExecutionStrategy: OperationExecutionStrategy {
    private let condition: (Operation) -> Bool

    public init(_ condition: @escaping (Operation) -> Bool) {
        self.condition = condition
    }

    public override func canExecute(operation: Operation) -> Bool {
        return condition(operation)
    }
}

