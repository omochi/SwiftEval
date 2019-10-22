import Foundation

public final class SwiftPMEnvironment: BuildEnvironment {
    public var configuration: String
    public var buildDirectory: URL
    
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
    }
    
    public func module(name: String) throws -> Module {
        let objectListFile = buildDirectory
            .appendingPathComponent(configuration)
            .appendingPathComponent("\(name).product")
            .appendingPathComponent("Objects.LinkFileList")
        let objectFiles = try Utils.readStringLists(file: objectListFile)
            .map { URL(fileURLWithPath: $0) }
        return Module(objectFiles: objectFiles)
    }
}
