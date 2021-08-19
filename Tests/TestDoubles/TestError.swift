import Foundation

struct TestError: Error, Equatable {

    static let instance: TestError = TestError()
    static var uniqueInstance: TestError { return TestError() }

    let uuid = UUID()

    private init() { }
}
