
extension Task {

    public func onResult(_ handler: @escaping (Result<T, Error>) -> ()) -> Task<T> {
        resultOperation.addCompletionBlock { [weak resultOperation] in
            guard let result = resultOperation?.result else { return }
            handler(result)
        }
        return self
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

