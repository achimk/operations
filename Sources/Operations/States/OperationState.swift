
public enum OperationState: Int, Comparable {
    case ready
    case executing
    case finished

    public static func <(lhs: OperationState, rhs: OperationState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func ==(lhs: OperationState, rhs: OperationState) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
