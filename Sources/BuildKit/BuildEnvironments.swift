import Foundation

public enum BuildEnvironments {
    public static func detect() throws -> BuildEnvironment {
        guard let execPath = Bundle.main.executableURL else {
            throw MessageError("no executableURL")
        }
        var dir = execPath.deletingLastPathComponent()
        while true {
            if dir.path == "/" {
                throw MessageError("search build directory failed")
            }
            
            if dir.lastPathComponent == ".build" {
                return try SwiftPMEnvironment(executablePath: execPath)
            }
            
            if dir.lastPathComponent == "Products" {
//                return
                fatalError()
            }
            
            dir = dir.deletingLastPathComponent()
        }        
    }
}

