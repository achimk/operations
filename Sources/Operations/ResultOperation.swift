
open class ResultOperation<Success>: AsyncOperation {

    // MARK: Properties

    public private(set) var result: Result<Success, Error>?
    private let transform: (@escaping (Result<Success, Error>) -> ()) -> Cancelable
    private var cancelToken: Cancelable?

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
        return OperationExecutionStrategy.allowed
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
            cancelToken = transform(completion)
        }
    }
}
