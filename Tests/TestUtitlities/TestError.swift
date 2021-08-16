import Foundation

struct TestError: Error, Equatable {

    static let instance: TestError = TestError()

    private init() { }
}
