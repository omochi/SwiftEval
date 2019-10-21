import Foundation

internal let fm = FileManager.default

internal enum Utils {
    public static let binaryDirectory: URL = formBinaryDirectory()
    
    private static func formBinaryDirectory() -> URL {
        guard let executableURL = Bundle.main.executableURL else {
            preconditionFailure("no executableURL")
        }
        
        return executableURL.deletingLastPathComponent()
    }
    
    public static func randomString() -> String {
        let chars: [Character] = """
        abcdefghijklmnopqrstuvwxyz\
        ABCDEFGHIJKLMNOPQRSTUVWXYZ\
        0123456789
        """
            .map { $0 }
        
        let len = 8
        return String((0..<len).map { (_) in chars.randomElement()! })
    }
    
    public static func createTemporaryDirectory() -> URL {
        let dir = fm.temporaryDirectory
            .appendingPathComponent("SwiftEval")
            .appendingPathComponent(randomString())
        return dir
    }
}
