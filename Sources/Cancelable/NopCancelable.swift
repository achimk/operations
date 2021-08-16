
/// Nop == No Operation
public final class NopCancelable: Cancelable {

    public init() { }

    public func cancel() {
        // does nothing
    }
}
