import Foundation

extension Result {

    init(_ value: Success) {
        self = .success(value)
    }

    init(_ error: Failure) {
        self = .failure(error)
    }
}

extension Result {

    var value: Success? { return analyze(ifSuccess: { $0 }, ifFailure: { _ in nil }) }

    var error: Failure? { return analyze(ifSuccess: { _ in nil }, ifFailure: { $0 }) }

    var isSuccess: Bool { return analyze(ifSuccess: { true }, ifFailure: { false }) }

    var isFailure: Bool { return !isSuccess }

}

extension Result {

    func ifSuccess(_ perform: (Success) -> ()) {
        analyze(ifSuccess: perform, ifFailure: { _ in })
    }

    func ifFailure(_ perform: (Failure) -> ()) {
        analyze(ifSuccess: { _ in }, ifFailure: perform)
    }

    func analyze<T>(ifSuccess: () throws -> T, ifFailure: () throws -> T) rethrows -> T {
        switch self {
        case .success: return try ifSuccess()
        case .failure: return try ifFailure()
        }
    }

    func analyze<T>(ifSuccess: (Success) throws -> T, ifFailure: (Failure) throws -> T) rethrows -> T {
        switch self {
        case .success(let value): return try ifSuccess(value)
        case .failure(let error): return try ifFailure(error)
        }
    }
}

extension Result where Success == Void {

    static func success() -> Result<Success, Failure> {
        return Result.success(())
    }
}

extension Result {

    func throwsIfFailure() throws {
        switch self {
        case .success: return
        case .failure(let error): throw error
        }
    }
}
