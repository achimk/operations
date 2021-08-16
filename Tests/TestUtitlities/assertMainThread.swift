import Foundation

func assertMainThread(file: StaticString = #file, line: UInt = #line) {
    assert(Thread.isMainThread, "Should be called on main thread!", file: file, line: line)
}
