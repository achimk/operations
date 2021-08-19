
open class AsyncTransformOperation<Input, Output>: AsyncResultOperation<Output> {

    fileprivate final class InputResult {
        var result: Result<Input, Error>?

        init(_ result: Result<Input, Error>?) {
            self.result = result
        }
    }

    // MARK: NSObject

    @objc dynamic override class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state", "input"]
    }

    // MARK: Properties

    private let inputQueue = DispatchQueue(
        label: "OperationQueue.AsyncTransformOperation.Input",
        attributes: .concurrent)

    private var unsafeInput: InputResult

    private var input: Result<Input, Error>? {
        get {
            return inputQueue.sync(execute: { unsafeInput.result })
        }
        set {
            assert(newValue != nil && input == nil, "Invalid set state for sink operation!")
            willChangeValue(forKey: "input")
            inputQueue.sync(
                flags: .barrier,
                execute: { unsafeInput.result = newValue })
            didChangeValue(forKey: "input")
        }
    }

    // MARK: State Flags

    open override var isReady: Bool {
        return input != nil && super.isReady
    }

    // MARK: Init

    public convenience init(input result: Result<Input, Error>? = nil,
                            transform: @escaping (Input) throws -> Output)
    {
        self.init(input: result, transform: { (input, completion) in
            let result = Result<Output, Error>(catching: { try transform(input) })
            completion(result)
            return Cancelables.make()
        })
    }

    public convenience init(input result: Result<Input, Error>? = nil,
                            transform: @escaping (Input) -> Result<Output, Error>)
    {
        self.init(input: result, transform: { (input, completion) in
            let result = transform(input)
            completion(result)
            return Cancelables.make()
        })
    }

    public convenience init(input result: Result<Input, Error>? = nil,
                            transform: @escaping (Input, @escaping (Result<Output, Error>) -> ()) -> Cancelable)
    {
        self.init(input: result, transform: transform, recover: { (error, completion) in
            completion(.failure(error))
            return Cancelables.make()
        })
    }

    public init(input result: Result<Input, Error>? = nil,
                transform: @escaping (Input, @escaping (Result<Output, Error>) -> ()) -> Cancelable,
                recover: @escaping (Error, @escaping (Result<Output, Error>) -> ()) -> Cancelable)
    {
        let input = InputResult(result)
        self.unsafeInput = input
        super.init { (completion) -> Cancelable in
            guard let result = input.result else {
                assertionFailure("Empty state of input should never happen!")
                return Cancelables.make()
            }
            switch result {
            case .success(let value):
                return transform(value, completion)
            case .failure(let error):
                return recover(error, completion)
            }
        }
    }

    public override func onExecute(completion: @escaping (Result<Output, Error>) -> ()) {
        assert(input != nil, "Empty state of input should never happen!")
        if isCancelled {
            switch input {
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.failure(OperationCanceledError()))
            }
        } else {
            onTransform(completion: completion)
        }
    }

    // MARK: Sink

    public func sink(value: Input) {
        sink(result: .success(value))
    }

    public func sink(error: Error) {
        sink(result: .failure(error))
    }

    public func sink(result: Result<Input, Error>) {
        if input == nil {
            input = result
        }
    }
}
