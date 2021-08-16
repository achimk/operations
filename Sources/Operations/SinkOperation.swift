
open class SinkOperation<Input, Output, Failure: Error>: ResultOperation<Output, Failure> {

    fileprivate final class InputResult {
        var result: Result<Input, Failure>?

        init(_ result: Result<Input, Failure>?) {
            self.result = result
        }
    }

    // MARK: NSObject

    @objc dynamic override class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state", "input"]
    }

    // MARK: Properties

    private let inputQueue = DispatchQueue(
        label: "OperationQueue.SinkOperation.Input",
        attributes: .concurrent)

    private var unsafeInput: InputResult

    private var input: Result<Input, Failure>? {
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

    // MARK: State

    open override var isReady: Bool {
        return input != nil && super.isReady
    }

    // MARK: Init

    public convenience init(input result: Result<Input, Failure>? = nil,
                            transform: @escaping (Input) -> Result<Output, Failure>)
    {
        self.init(input: result, transform: { (input, completion) in
            let result = transform(input)
            completion(result)
            return Cancelables.make()
        })
    }

    public init(input result: Result<Input, Failure>? = nil,
                transform: @escaping (Input, @escaping (Result<Output, Failure>) -> ()) -> Cancelable)
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
                completion(.failure(error))
                return Cancelables.make()
            }
        }
    }

    // MARK: Sink

    public func sink(value: Input) {
        sink(result: .success(value))
    }

    public func sink(error: Failure) {
        sink(result: .failure(error))
    }

    public func sink(result: Result<Input, Failure>) {
        if input == nil {
            input = result
        }
    }
}
