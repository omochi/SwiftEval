import Foundation

public protocol BuildEnvironment: AnyObject {
    var configuration: String { get }
    
    func module(name: String) throws -> Module
}
