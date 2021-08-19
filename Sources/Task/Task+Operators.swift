
extension Task {

    public func bind<U>(_ transform: @escaping (T, @escaping (Result<U, Error>) -> ()) -> Cancelable) -> Task<U> {
        let outputOperation = TransformOperation(transform: transform)
        resultOperation.addCompletionBlock { [weak resultOperation] in
            guard let result = resultOperation?.result else { return }
            outputOperation.sink(result: result)
        }
        outputOperation.addDependency(resultOperation)

        return Task<U>(
            resultOperation: outputOperation,
            operations: operations + [outputOperation],
            queue: queue)
    }

    public func map<U>(_ transform: @escaping (T) throws -> U) -> Task<U> {
        let outputOperation = TransformOperation<T, U> { (value, completion) -> Cancelable in
            completion(Result(catching: { try transform(value) }))
            return Cancelables.make()
        }
        resultOperation.addCompletionBlock { [weak resultOperation] in
            guard let result = resultOperation?.result else { return }
            outputOperation.sink(result: result)
        }
        outputOperation.addDependency(resultOperation)

        return Task<U>(
            resultOperation: outputOperation,
            operations: operations + [outputOperation],
            queue: queue)
    }
}
