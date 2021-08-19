
final class SpyAsyncResultOperation<Success>: AsyncResultOperation<Success> {

    // MARK: Properties

    var onPreCancel: ((AsyncResultOperation<Success>) -> ())?
    var onPostCancel: ((AsyncResultOperation<Success>) -> ())?
    var onPreExecute: ((AsyncResultOperation<Success>) -> ())?
    var onPostExecute: ((AsyncResultOperation<Success>) -> ())?
    var onPreFinish: ((AsyncResultOperation<Success>) -> ())?
    var onPostFinish: ((AsyncResultOperation<Success>) -> ())?

    // MARK: Public

    override func onCancel() {
        onPreCancel?(self)
        super.onCancel()
        onPostCancel?(self)
    }

    override func onExecute(completion: @escaping (Result<Success, Error>) -> ()) {
        onPreExecute?(self)
        super.onExecute(completion: completion)
        onPostExecute?(self)
    }

    override func onFinish() {
        onPreFinish?(self)
        super.onFinish()
        onPostFinish?(self)
    }
}
