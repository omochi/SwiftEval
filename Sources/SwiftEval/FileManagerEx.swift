import Foundation

internal extension FileManager {
    func changeCurrentDirectory(at url: URL) throws {
        guard changeCurrentDirectoryPath(url.path) else {
            throw MessageError("changeCurrentDirectory failed: \(url.path)")
        }
    }
}
