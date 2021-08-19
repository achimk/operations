
final class SpyResultOperation<Success>: ResultOperation<Success> {

    // MARK: Properties

    var onPreCancel: ((ResultOperation<Success>) -> ())?
    var onPostCancel: ((ResultOperation<Success>) -> ())?
    var onPreExecute: ((ResultOperation<Success>) -> ())?
    var onPostExecute: ((ResultOperation<Success>) -> ())?
    var onPreFinish: ((ResultOperation<Success>) -> ())?
    var onPostFinish: ((ResultOperation<Success>) -> ())?

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
