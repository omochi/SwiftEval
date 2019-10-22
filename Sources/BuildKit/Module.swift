import Foundation

public struct Module {
    public var objectFiles: [URL]
    
    public init(objectFiles: [URL]) {
        self.objectFiles = objectFiles
    }
}
