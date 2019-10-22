import Foundation

public enum Utils {
    public static func readStringLists(file: URL) throws -> [String] {
        let text = try String(contentsOf: file)
        let list: [String] = text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return list
    }
}
