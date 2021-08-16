import Foundation

extension Operation {

    func addCompletionBlock(_ block: @escaping () -> ()) {
        guard let existing = completionBlock else {
            completionBlock = block
            return
        }

        completionBlock = {
            existing()
            block()
        }
    }

    func addDependencies(_ dependencies: [Operation]) {
        dependencies.forEach { addDependency($0) }
    }
}

extension Operation: Cancelable { }
