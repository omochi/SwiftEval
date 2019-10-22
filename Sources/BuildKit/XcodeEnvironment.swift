import Foundation

public final class XcodeEnvironment: BuildEnvironment {
    public var configuration: String
    public var buildDirectory: URL
    public var modulesDirectory: URL { buildDirectory }
    public var binaryDirectory: URL { buildDirectory }
    
    public init(executablePath: URL) throws {
        var _configuration: String!
        var _buildDirectory: URL!
        
        var dir = executablePath.deletingLastPathComponent()
        
        while true {
            if dir.path == "/" {
                throw MessageError("scan failed")
            }
            
            let parentDir = dir.deletingLastPathComponent()
            
            if parentDir.lastPathComponent == "Products" {
                _configuration = dir.lastPathComponent
                _buildDirectory = dir
                break
            }

            dir = dir.deletingLastPathComponent()
        }
        
        guard let c = _configuration else {
            throw MessageError("failed to detect configuration")
        }
        self.configuration = c
        self.buildDirectory = _buildDirectory
    }
}
