import Foundation

extension Operation {

    public func addCompletionBlock(_ block: @escaping () -> ()) {
        guard let existing = completionBlock else {
            completionBlock = block
            return
        }

        completionBlock = {
            existing()
            block()
        }
    }

    public func addDependencies(_ dependencies: Operation...) {
        dependencies.forEach { addDependency($0) }
    }

    public func addDependencies(_ dependencies: [Operation]) {
        dependencies.forEach { addDependency($0) }
    }

    public func hasCanceledDependencies() -> Bool {
        return dependencies.reduce(false){ $0 || $1.isCancelled }
    }
}

extension Operation: Cancelable { }
