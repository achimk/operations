import Foundation

typealias Completer<T> = (Result<T, Error>) -> ()
