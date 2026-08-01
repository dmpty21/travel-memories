import Foundation

enum CSVParser {
    /// Parses RFC 4180-ish CSV text into rows of fields, handling quoted fields
    /// (including embedded commas, newlines, and "" escaped quotes).
    static func parse(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var field = ""
        var insideQuotes = false

        let chars = Array(text)
        var i = 0
        while i < chars.count {
            let char = chars[i]

            if insideQuotes {
                if char == "\"" {
                    if i + 1 < chars.count && chars[i + 1] == "\"" {
                        field.append("\"")
                        i += 2
                        continue
                    }
                    insideQuotes = false
                    i += 1
                    continue
                }
                field.append(char)
                i += 1
                continue
            }

            switch char {
            case "\"":
                insideQuotes = true
            case ",":
                currentRow.append(field)
                field = ""
            case "\n":
                currentRow.append(field)
                field = ""
                rows.append(currentRow)
                currentRow = []
            case "\r":
                break
            default:
                field.append(char)
            }
            i += 1
        }

        if !field.isEmpty || !currentRow.isEmpty {
            currentRow.append(field)
            rows.append(currentRow)
        }

        return rows.filter { !($0.count == 1 && $0[0].trimmingCharacters(in: .whitespaces).isEmpty) }
    }
}
