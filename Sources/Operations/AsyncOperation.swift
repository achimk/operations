import Foundation

/// An abstract class that makes building simple asynchronous operations easy.
/// Subclasses must implement `onExecute()` to perform any work and call
/// `finish()` when they are done. All `NSOperation` work will be handled
/// automatically.
open class AsyncOperation: Operation {

    // MARK: NSObject

    @objc dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state"]
    }

    @objc dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }

    @objc dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }

    // MARK: State

    private let stateQueue = DispatchQueue(
        label: "OperationQueue.AysncOperation.State",
        attributes: .concurrent)

    private var unsafeState: OperationState = .ready

    private(set) var state: OperationState {
        get {
            return stateQueue.sync(execute: { unsafeState })
        }
        set {
            willChangeValue(forKey: "state")
            stateQueue.sync(
                flags: .barrier,
                execute: { unsafeState = newValue })
            didChangeValue(forKey: "state")
        }
    }

    // MARK: State Flags

    open override var isReady: Bool {
        return state == .ready && super.isReady
    }

    open override var isExecuting: Bool {
        return state == .executing
    }

    open override var isFinished: Bool {
        return state == .finished
    }

    // MARK: Execution Strategy

    private lazy var exectutionStrategy: OperationExecutionStrategy = makeExecutionStrategy()

    public func makeExecutionStrategy() -> OperationExecutionStrategy {
        return OperationExecutionStrategy
            .isNotCanceled
            .and(.hasNotCanceledDependencies)
    }

    // MARK: Foundation.Operation

    public final override func start() {
        guard exectutionStrategy.canExecute(operation: self) else {
            finish()
            return
        }

        state = .executing
        main()
    }

    public final override func main() {
        assert(state == .executing, "This operation must be performed on an operation queue.")
        onExecute()
    }

    public final override func cancel() {
        guard !isCancelled else { return }
        onCancel()
        super.cancel()
    }

    // MARK: Public Override

    open func onExecute() {
        abstractMethod()
    }

    open func onFinish() {
        // Subclasses can override this method.
    }

    open func onCancel() {
        // Subclasses can override this method.
    }

    /// Call this function after any work is done or after a call to `cancel()`
    /// to move the operation into a completed state.
    public final func finish() {
        guard state != .finished else { return }
        onFinish()
        state = .finished
    }

    // MARK: Safe Checks

    public final var userInitiated: Bool {
        get {
            return qualityOfService == .userInitiated
        }
        set {
            assert(state < .executing, "Cannot modify userInitiated after execution has begun.")
            qualityOfService = newValue ? .userInitiated : .default
        }
    }

    public final override func addDependency(_ operation: Foundation.Operation) {
        assert(state < .executing, "Dependencies cannot be modified after execution has begun.")
        super.addDependency(operation)
    }

    public final override func waitUntilFinished() {
        /*
            Waiting on operations is almost NEVER the right thing to do. It is
            usually superior to use proper locking constructs, such as `dispatch_semaphore_t`
            or `dispatch_group_notify`, or even `NSLocking` objects. Many developers
            use waiting when they should instead be chaining discrete operations
            together using dependencies.

            To reinforce this idea, invoking `waitUntilFinished()` will crash your
            app, as incentive for you to find a more appropriate way to express
            the behavior you're wishing to create.
        */
        fatalError("Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.")
    }
}

