
public struct Cancelables {

    public static func make() -> Cancelable {
        return NopCancelable()
    }

    public static func make(_ onDidCancel: @escaping () -> ()) -> Cancelable {
        return AnyCancelable(onDidCancel)
    }
}
