
public final class AsyncBlockOperation: AsyncOperation {

    // MARK: Properties

    private let block: (@escaping () -> ()) -> ()

    // MARK: Init

    public convenience init(block: @escaping () -> ()) {
        self.init { completion in
            block()
            completion()
        }
    }

    public init(block: @escaping (@escaping () -> ()) -> ()) {
        self.block = block
    }

    // MARK: Public Override

    public override func onExecute() {
        block { [weak self] in
            self?.finish()
        }
    }
}
