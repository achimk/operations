
class Box<T> {
    fileprivate(set) var value: T

    init(_ value: T) {
        self.value = value
    }

    func getValue() -> T {
        return value
    }
}

class MutableBox<T>: Box<T> {

    func set(value: T) {
        self.value = value
    }
}
