import Foundation

/// Left-aligned columns, two spaces apart; last column unpadded.
func printTable(headers: [String], rows: [[String]]) {
    var widths = headers.map(\.count)
    for row in rows {
        for (i, cell) in row.enumerated() where i < widths.count {
            widths[i] = max(widths[i], cell.count)
        }
    }
    func line(_ cells: [String]) -> String {
        cells.enumerated().map { i, cell in
            i == cells.count - 1 ? cell : cell + String(repeating: " ", count: widths[i] - cell.count)
        }.joined(separator: "  ")
    }
    print(line(headers))
    rows.forEach { print(line($0)) }
}
