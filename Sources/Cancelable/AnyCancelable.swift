
public final class AnyCancelable: Cancelable {
    private let lock = NSLock()
    private(set) var isSealed = false
    private let onDidCancel: () -> ()

    public init(_ onDidCancel: @escaping () -> ()) {
        self.onDidCancel = onDidCancel
    }

    public func isCanceled() -> Bool {
        return isSealed
    }

    public func cancel() {
        if isSealed {
            return
        }

        lock.lock()
        defer { lock.unlock() }

        if isSealed {
            return
        }

        onDidCancel()
        isSealed = true
    }
}
