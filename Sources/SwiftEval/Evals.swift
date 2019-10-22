import Foundation
import BuildKit

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
    
    public static func eval(imports: [String] = [],
                            source: String) throws {
        let fn = try compileFunction0(imports: imports,
                                      returnType: Void.self,
                                      source: source)
        fn()
    }
    
    public static func compileFunction0<R>(
        imports: [String] = [],
        returnType: R.Type,
        source: String)
        throws -> () -> R
    {
        let name = generateAnonymousName()
        
        let imports = ["SwiftEval"] + imports
        
        let importLines = imports
            .map { "import \($0)" }
            .joined(separator: "\n")
        
        let d = String(repeating: " ", count: 4)
        let ____d = String(repeating: " ", count: 8)
        let ________d = String(repeating: " ", count: 12)
        
        let source = """
        \(importLines)
        
        extension SwiftEvalPrivates {
        \(d)@_dynamicReplacement(for: function0)
        \(d)public var __function_\(name): (() -> Any)? {
        \(____d)func fn() -> \(returnType) {
        \(________d)\(source)
        \(____d)}
        \(____d)return fn
        \(d)}
        }
        """
        
        try compileAndLoad(name: name,
                           imports: imports,
                           source: source)
        
        guard let fn = SwiftEvalPrivates.shared.function0 else {
            throw MessageError("load function failed")
        }
        
        return { fn() as! R }
    }
    
    public static func compileFunction1<P1, R>(
        imports: [String] = [],
        parameter1Type: P1.Type,
        returnType: R.Type,
        source: String)
        throws -> (P1) -> R
    {
        let name = generateAnonymousName()

        let imports = ["SwiftEval"] + imports
        
        let importLines = imports
            .map { "import \($0)" }
            .joined(separator: "\n")
        
        let d = String(repeating: " ", count: 4)
        let ____d = String(repeating: " ", count: 8)
        let ________d = String(repeating: " ", count: 12)
        
        let source = """
        \(importLines)
        
        extension SwiftEvalPrivates {
        \(d)@_dynamicReplacement(for: function1)
        \(d)public var __function_\(name): ((Any) -> Any)? {
        \(____d)func fn(_ parameter1: \(parameter1Type)) -> \(returnType) {
        \(________d)\(source)
        \(____d)}
        \(____d)return { (parameter1: Any) -> Any in
        \(________d)fn(parameter1 as! \(parameter1Type))
        \(____d)}
        \(d)}
        }
        """
        
        try compileAndLoad(name: name,
                           imports: imports,
                           source: source)
        
        guard let fn = SwiftEvalPrivates.shared.function1 else {
            throw MessageError("load function failed")
        }
        
        return { (parameter1: P1) -> R in
            fn(parameter1) as! R
        }
    }
    
    private static func compileAndLoad(
        name: String,
        imports: [String],
        source: String) throws
    {
        let env = try BuildEnvironments.detect()

        let tempDir = Utils.createTemporaryDirectory()
        try fm.createDirectory(at: tempDir, withIntermediateDirectories: true)
        try source.write(to: tempDir.appendingPathComponent("code.swift"),
                         atomically: true, encoding: .utf8)
        
        try fm.changeCurrentDirectory(at: tempDir)
        
        let modulesDir = env.modulesDirectory
        print(modulesDir.path)
        
        var args: [String] = [
            "/usr/bin/swiftc",
            "-emit-library",
            "-module-name", name,
            "-I", modulesDir.path
        ]
        
        let libFiles = imports.map { (module) in
            env.binaryDirectory
                .appendingPathComponent("lib\(module).dylib")
        }
        
        args += libFiles.map { $0.path }
        
        args += ["code.swift"]
        
        print(args)
        
        let ret = Commands.run(args)
        guard ret.statusCode == EXIT_SUCCESS else {
            throw Commands.Error(ret.standardError)
        }
        
        let libPath = tempDir.appendingPathComponent("lib\(name).dylib")
        
        guard let _ = dlopen(libPath.path, RTLD_NOW) else {
            throw MessageError("dlopen failed: \(libPath.path)")
        }
    }
}

