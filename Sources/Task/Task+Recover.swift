
extension Task {

    public func recover(_ transform: @escaping (Error, @escaping (Result<T, Error>) -> ()) -> Cancelable) -> Task<T> {
        let outputOperation = AsyncTransformOperation<T, T>(transform: { (value, completion) in
            completion(.success(value))
            return Cancelables.make()
        }, recover: { (error, completion) in
            return transform(error, completion)
        })
        resultOperation.addCompletionBlock { [weak resultOperation] in
            guard let result = resultOperation?.result else { return }
            outputOperation.accept(result: result)
        }
        outputOperation.addDependency(resultOperation)

        return Task<T>(
            resultOperation: outputOperation,
            operations: operations + [outputOperation])
    }

    public func recover(_ transform: @escaping (Error) throws -> T) -> Task<T> {
        return recover { (error, completion) -> Cancelable in
            completion(Result(catching: { try transform(error) }))
            return Cancelables.make()
        }
    }
}
