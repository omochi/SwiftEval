import Foundation

public enum Evals {
    private static var counter: Int = 0
    
    private static func generateCount() -> Int {
        let ret = counter
        counter += 1
        return ret
    }
    
    private static func generateAnonymousName() -> String {
        let c = generateCount()
        return String(format: "SwiftEvalAnonymous%04d", c)
    }
    
    public static func eval(source: String) throws {
        let fn = try compileFunction0(returnType: Void.self, source: source)
        fn()
    }
    
    public static func compileFunction0<R>(
        returnType: R.Type,
        source: String) throws -> () -> R
    {
        let name = generateAnonymousName()
        
        let wholeSource = """
import SwiftEval

extension SwiftEvalPrivates {
    @_dynamicReplacement(for: function0)
    public var function0_\(name): (() -> Any)? {
        func fn() -> \(returnType) {
            \(source)
        }
        return fn
    }
}
"""
        
        let tempDir = Utils.createTemporaryDirectory()
        try fm.createDirectory(at: tempDir, withIntermediateDirectories: true)
        try wholeSource.write(to: tempDir.appendingPathComponent("code.swift"),
                              atomically: true, encoding: .utf8)
        
        try fm.changeCurrentDirectory(at: tempDir)
        
        let binDir = Utils.binaryDirectory
        
        let args: [String] = [
            "/usr/bin/swiftc",
            "-emit-library",
            "-I", binDir.path,
            binDir.appendingPathComponent("libSwiftEval.dylib").path,
            "-module-name", name,
            "code.swift"
        ]
        let ret = Commands.run(args)
        guard ret.statusCode == EXIT_SUCCESS else {
            throw Commands.Error(ret.standardError)
        }
        
        let libPath = tempDir.appendingPathComponent("lib\(name).dylib")
        
        guard let _ = dlopen(libPath.path, RTLD_NOW) else {
            throw MessageError("dlopen failed: \(libPath.path)")
        }
        
        guard let fn = SwiftEvalPrivates.shared.function0 else {
            throw MessageError("load function failed")
        }
        
        return { fn() as! R }
    }
}

