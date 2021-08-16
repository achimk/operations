
enum OperationState: Int, Comparable {
    case ready
    case executing
    case finished

    static func <(lhs: OperationState, rhs: OperationState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    static func ==(lhs: OperationState, rhs: OperationState) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
