import XCTest
import Operations

class AnyCancelableTests: XCTestCase {

    func test_cancelClosure_shouldBeInvoked() {
        var invoked = false
        let token = AnyCancelable { invoked = true }

        token.cancel()

        XCTAssertTrue(invoked)
    }

    func test_cancelClosure_shouldBeInvokedOnlyOnce() {
        var calls = 0
        let token = AnyCancelable { calls += 1 }

        token.cancel()
        token.cancel()
        token.cancel()

        XCTAssertEqual(calls, 1)
    }

    func test_invokeCancel_shouldBeMarkedAsCanceled() {
        let token = AnyCancelable {  }

        token.cancel()

        XCTAssertTrue(token.isCanceled())
    }

    func test_notInvokeCancel_shouldBeMarkedAsCanceled() {
        let token = AnyCancelable {  }

        XCTAssertFalse(token.isCanceled())
    }
}
