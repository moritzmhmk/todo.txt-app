import Foundation

struct TodoParser {

    static func parse(line: String) -> TodoItem {
        var item = TodoItem()
        var words = line.split(separator: " ").map { String($0) }

        // Step 1: check for completion
        if let word = words.first, word.lowercased() == "x" {
            item.completed = true
            words.removeFirst()
        }

        // Step 2: check for priority
        if let word = words.first, word.count == 3, word.first == "(", word.last == ")" {
            let prioChar = word[word.index(after: word.startIndex)]

            if prioChar >= "A" && prioChar <= "Z" {
                item.priority = prioChar
                words.removeFirst()
            }
        }

        // Step 3: check for dates (either only creationDate or completionDate followed by creationDate).
        if let word = words.first, let firstDate = parseDate(word) {

            if item.completed {
                if words.count > 1, let secondDate = parseDate(words[1]) {
                    item.completionDate = firstDate
                    item.creationDate = secondDate
                    words.removeFirst(2)
                } else {
                    item.creationDate = firstDate
                    words.removeFirst()
                }
            } else {
                item.creationDate = firstDate
                words.removeFirst()
            }
        }

        // Step 4: remaining words are tokens
        // TODO handle tags (@context, +project, key:value)
        item.tokens = words.map { Token.word($0) }

        return item
    }

    private static func parseDate(_ s: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: s)
    }
}
