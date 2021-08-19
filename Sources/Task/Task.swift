import Foundation

public final class Task<T> {
    internal let resultOperation: ResultOperation<T>
    internal let operations: [Operation]

    public static func create() -> Task<T> where T == Void {
        return Task(value: ())
    }

    public convenience init(value: T) {
        self.init(result: .success(value))
    }

    public convenience init(error: Error) {
        self.init(result: .failure(error))
    }

    public init(result: Result<T, Error>) {
        self.resultOperation = ResultOperation(result: result)
        self.operations = [resultOperation]
    }

    internal init(resultOperation: ResultOperation<T>,
                  operations: [Foundation.Operation])
    {
        self.resultOperation = resultOperation
        self.operations = operations
    }

    @discardableResult
    public func run(on queue: OperationQueue = .init(),
                    completion: @escaping (Result<T, Error>) -> () = { _ in }) -> Cancelable
    {
        resultOperation.addCompletionBlock { [weak resultOperation] in
            guard let result = resultOperation?.result else { return }
            completion(result)
        }
        queue.addOperations(operations)

        return Cancelables.make { [operations] in
            operations.forEach { $0.cancel() }
        }
    }
}
