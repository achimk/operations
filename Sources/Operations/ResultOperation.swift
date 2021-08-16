
open class ResultOperation<Success, Failure: Error>: AsyncOperation {
    private(set) var result: Result<Success, Failure>?
    private let transform: (@escaping (Result<Success, Failure>) -> ()) -> Cancelable
    private var cancelToken: Cancelable?

    // MARK: Init

    public init(result: Result<Success, Failure>) {
        self.transform = { completion -> Cancelable in
            completion(result)
            return Cancelables.make()
        }
    }

    public init(transform: @escaping (@escaping (Result<Success, Failure>) -> ()) -> Cancelable) {
        self.transform = transform
    }

    // MARK: Public

    public override func onCancel() {
        cancelToken?.cancel()
        cancelToken = nil
    }

    public override func onExecute() {
        cancelToken = transform { [weak self] result in
            self?.result = result
            self?.finish()
        }
    }
}
