import Foundation

public func onFinish(_ operations: [Operation], completion: @escaping () -> ()) {
    let doneOperation = finishOpration(operations, completion: completion)
    OperationQueue().addOperation(doneOperation)
}

public func finishOpration(_ operations: [Operation], completion: @escaping () -> ()) -> Operation {
    let doneOperation = BlockOperation(block: completion)
    operations.forEach { doneOperation.addDependency($0) }
    return doneOperation
}

public func pipelineDependency(for operations: [Operation]) {
    guard operations.count > 1 else { return }
    let range = 0..<operations.count - 1
    range.forEach { (index) in
        let current = operations[index]
        let next = operations[index + 1]
        next.addDependency(current)
    }
}
