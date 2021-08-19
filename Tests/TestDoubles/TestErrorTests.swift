import XCTest

class TestErrorTests: XCTestCase {

    func test_errorTestInstance_shouldAlwaysBeEqual() {
        XCTAssertEqual(TestError.instance, TestError.instance)
    }

    func test_errorTestUniqueInstance_shouldAlwaysBeUnique() {
        XCTAssertNotEqual(TestError.uniqueInstance, TestError.uniqueInstance)
    }

    func test_errorTestInstance_shouldNotEqualToUniqueInstance() {
        XCTAssertNotEqual(TestError.instance, TestError.uniqueInstance)
    }
}
