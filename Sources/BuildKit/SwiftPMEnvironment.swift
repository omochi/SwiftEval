import Foundation

public final class SwiftPMEnvironment: BuildEnvironment {
    public var configuration: String
    public var buildDirectory: URL
    public var modulesDirectory: URL { buildDirectory }
    public var binaryDirectory: URL { buildDirectory }
    
    public init(executablePath: URL) throws {
        var _configuration: String?
        var _buildDirectory: URL!
        
        var dir = executablePath.deletingLastPathComponent()
        
        while true {
            let name = dir.lastPathComponent
            
            if dir.path == "/" {
                throw MessageError("scan failed")
            }
            
            if _configuration == nil {
                if ["debug", "release"].contains(name) {
                    _configuration = name
                }
            }
            
            if name == ".build" {
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
            .appendingPathComponent(configuration)
    }
    
    public func module(name: String) throws -> Module {
        let buildDir = buildDirectory
            .appendingPathComponent("\(name).build")
        guard FileManager.default.fileExists(atPath: buildDir.path) else {
            throw MessageError("no module build directory: \(buildDir.path)")
        }

        var objectFiles: [URL] = []
        for name in try FileManager.default
            .contentsOfDirectory(at: buildDir, includingPropertiesForKeys: nil, options: [])
        {
            if name.pathExtension == "o" {
                objectFiles.append(name)
            }
        }
        return Module(objectFiles: objectFiles)
    }
}
