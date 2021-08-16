import Foundation

public class Task<T> {
    private let resultOperation: ResultOperation<T, Error>
    private let operations: [Operation]
    private let queue: OperationQueue

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
        self.queue = OperationQueue()
    }

    private init(resultOperation: ResultOperation<T, Error>,
                 operations: [Foundation.Operation],
                 queue: OperationQueue)
    {
        self.resultOperation = resultOperation
        self.operations = operations
        self.queue = queue
    }

    @discardableResult
    public func run(_ completion: @escaping (Result<T, Error>) -> () = { _ in }) -> Cancelable {
        var cancels: [Cancelable] = []
        let inputOperation = resultOperation
        let completeOperation = BlockOperation {
            guard let result = inputOperation.result else { return }
            completion(result)
        }
        completeOperation.addDependency(inputOperation)

        let all = operations + [completeOperation]
        all.forEach { (operation) in
            cancels.append(operation)
            queue.addOperation(operation)
        }

        return Cancelables.make {
            cancels.forEach { $0.cancel() }
        }
    }
}

extension Task {

    public static func sink(_ transform: @escaping (@escaping (Result<T, Error>) -> ()) -> Cancelable) -> Task<T> {
        return Task<Void>(value: ()).bind { (_, completion) in
            return transform(completion)
        }
    }

    public func bind<U>(_ transform: @escaping (T, @escaping (Result<U, Error>) -> ()) -> Cancelable) -> Task<U> {
        let inputOperation = resultOperation
        let outputOperation = SinkOperation(transform: transform)
        let passOnOperation = BlockOperation {
            guard let result = inputOperation.result else { return }
            outputOperation.sink(result: result)
        }

        passOnOperation.addDependency(inputOperation)
        outputOperation.addDependency(passOnOperation)

        return Task<U>(
            resultOperation: outputOperation,
            operations: operations + [passOnOperation, outputOperation],
            queue: queue)
    }

    public func map<U>(_ transform: @escaping (T) throws -> U) -> Task<U> {
        let inputOperation = resultOperation
        let outputOperation = SinkOperation<T, U, Error> { (value, completion) -> Cancelable in
            completion(Result(catching: { try transform(value) }))
            return Cancelables.make()
        }
        let passOnOperation = BlockOperation {
            guard let result = inputOperation.result else { return }
            outputOperation.sink(result: result)
        }

        passOnOperation.addDependency(inputOperation)
        outputOperation.addDependency(passOnOperation)

        return Task<U>(
            resultOperation: outputOperation,
            operations: operations + [passOnOperation, outputOperation],
            queue: queue)
    }

}

extension Task {

    public func onResult(_ handler: @escaping (Result<T, Error>) -> ()) -> Task<T> {
        let inputOperation = resultOperation
        let passOnOperation = BlockOperation {
            guard let result = inputOperation.result else { return }
            handler(result)
        }

        passOnOperation.addDependency(inputOperation)

        return Task<T>(
            resultOperation: inputOperation,
            operations: operations + [passOnOperation],
            queue: queue)
    }

    public func onSuccess(_ handler: @escaping (T) -> ()) -> Task<T> {
        return onResult {
            switch $0 {
            case .success(let value): handler(value)
            case .failure: return
            }
        }
    }

    public func onFailure(_ handler: @escaping (Error) -> ()) -> Task<T> {
        return onResult {
            switch $0 {
            case .success: return
            case .failure(let error): handler(error)
            }
        }
    }
}
