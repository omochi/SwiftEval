import Foundation

internal enum Commands {
    public struct Error: LocalizedError, CustomStringConvertible {
        public var error: String
        
        public init(_ data: Data) {
            self.error = String(data: data, encoding: .utf8) ?? "invalid UTF-8 data"
        }
        
        public var errorDescription: String? { description }
        public var description: String { error }
    }
    
    public struct Result {
        public var statusCode: Int32
        public var standardOutput: Data
        public var standardError: Data
    }
    
    public static func run(_ args: [String]) -> Result {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: args[0])
        p.arguments = args[1...].map { $0 }
        
        var outData = Data()
        let outPipe = Pipe()
        outPipe.fileHandleForReading.readabilityHandler = { (h) in
            outData.append(h.availableData)
        }
        p.standardOutput = outPipe
        
        var errData = Data()
        let errPipe = Pipe()
        errPipe.fileHandleForReading.readabilityHandler = { (h) in
            errData.append(h.availableData)
        }
        p.standardError = errPipe
        
        p.launch()
        p.waitUntilExit()

        return Result(statusCode: p.terminationStatus,
                      standardOutput: outData,
                      standardError: errData)
    }
}
