import XCTest
import Operations

class TaskBenchmarkTests: TaskPipelineTests {

    // Run only for debug to discover invalid state changes over Operation implementation
    func test_multipeCalls_shouldPassAll() {
        for index in 0..<1000 {
            print("=> run: \(index)")
            test_runAsyncTasksInPipeline_shouldProduceCorrectResult()
        }
    }
}
