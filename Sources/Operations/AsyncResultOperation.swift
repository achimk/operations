
open class AsyncResultOperation<Success>: AsyncOperation {

    // MARK: Properties

    public private(set) var result: Result<Success, Error>?
    private let transform: (@escaping (Result<Success, Error>) -> ()) -> Cancelable

    // MARK: Cancel Token

    private let cancelTokenQueue = DispatchQueue(
        label: "OperationQueue.AsyncResultOperation.CancelToken",
        attributes: .concurrent)

    private var unsafeCancelToken: Cancelable?

    private var cancelToken: Cancelable? {
        get {
            return cancelTokenQueue.sync(execute: { unsafeCancelToken })
        }
        set {
            willChangeValue(forKey: "cancelToken")
            cancelTokenQueue.sync(
                flags: .barrier,
                execute: { unsafeCancelToken = newValue })
            didChangeValue(forKey: "cancelToken")
        }
    }

    // MARK: Init

    public init(result: Result<Success, Error>) {
        self.transform = { completion -> Cancelable in
            completion(result)
            return Cancelables.make()
        }
    }

    public init(transform: @escaping (@escaping (Result<Success, Error>) -> ()) -> Cancelable) {
        self.transform = transform
    }

    // MARK: Execution Strategy

    public override func makeExecutionStrategy() -> OperationExecutionStrategy {
        return OperationExecutionStrategy.alwaysAllowed
    }

    // MARK: Public Override

    public override func onCancel() {
        cancelToken?.cancel()
        cancelToken = nil
    }

    public final override func onExecute() {
        onExecute { [weak self] (result) in
            self?.result = result
            self?.finish()
        }
    }

    public func onExecute(completion: @escaping (Result<Success, Error>) -> ()) {
        if isCancelled {
            completion(.failure(OperationCanceledError()))
        } else {
            onTransform(completion: completion)
        }
    }

    public final func onTransform(completion: @escaping (Result<Success, Error>) -> ()) {
        assert(cancelToken == nil, "Cancel token already set")
        cancelToken = transform(completion)
    }
}
