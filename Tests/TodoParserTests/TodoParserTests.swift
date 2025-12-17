import XCTest

@testable import TodoParser

private func parseDate(_ s: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: s)
}

final class TodoParserTests: XCTestCase {

    func testPlain() {
        let line = "Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel"])
    }

    // MARK: - Priority
    func testPriority() {
        let line = "(A) Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertEqual(item.priority, "A")
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel"])
    }

    func testPriorityWithInvalidPosition() {
        let line = "Pack towel (A)"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel", "(A)"])
    }
    func testInvalidPriorityLowercase() {
        let line = "(a) Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(item.tokens.map { $0.description }, ["(a)", "Pack", "towel"])
    }
    func testInvalidPriorityNoSpace() {
        let line = "(A)->Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(item.tokens.map { $0.description }, ["(A)->Pack", "towel"])
    }

    // MARK: - Creation Date

    func testCreationDate() {
        let line = "1979-10-12 Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertEqual(item.creationDate, parseDate("1979-10-12"))
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel"])
    }

    func testCreationDateWithPriority() {
        let line = "(A) 1979-10-12 Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertEqual(item.priority, "A")
        XCTAssertNil(item.completionDate)
        XCTAssertEqual(item.creationDate, parseDate("1979-10-12"))
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel"])
    }

    func testCreationDateWithInvalidPosition() {
        let line = "(A) Pack towel 1979-10-12 "
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertEqual(item.priority, "A")
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel", "1979-10-12"])
    }

    func testCreationDateAndPriorityWithInvalidPosition() {
        let line = "1979-10-12 (A) Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertEqual(item.creationDate, parseDate("1979-10-12"))
        XCTAssertEqual(item.tokens.map { $0.description }, ["(A)", "Pack", "towel"])
    }

    // MARK: - Completed

    func testCompleted() {
        let line = "x Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertTrue(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel"])
    }

    func testCompletedWithPriority() {
        let line = "x (A) Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertTrue(item.completed)
        XCTAssertEqual(item.priority, "A")
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel"])
    }

    func testCompletedWithDates() {
        let line = "x 1979-10-14 1979-10-12 Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertTrue(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertEqual(item.completionDate, parseDate("1979-10-14"))
        XCTAssertEqual(item.creationDate, parseDate("1979-10-12"))
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel"])
    }

    func testCompletedWithOnlyOneDate() {
        let line = "x 1979-10-12 Pack towel"
        let item = TodoParser.parse(line: line)

        XCTAssertTrue(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertEqual(item.creationDate, parseDate("1979-10-12"))
        XCTAssertEqual(item.tokens.map { $0.description }, ["Pack", "towel"])
    }

    func testContext() {
        let line = "Pack towel @Home"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(
            item.tokens,
            [
                .word("Pack"),
                .word("towel"),
                .context("Home"),
            ]
        )
    }

    func testMultipleContexts() {
        let line = "@Earth Pack towel @Home"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(
            item.tokens,
            [
                .context("Earth"),
                .word("Pack"),
                .word("towel"),
                .context("Home"),
            ]
        )
    }

    func testInvalidContexts() {
        let line = "Pack towel @ E@rth"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(
            item.tokens,
            [
                .word("Pack"),
                .word("towel"),
                .word("@"),
                .word("E@rth"),
            ]
        )
    }

    func testProject() {
        let line = "Pack towel +travel"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(
            item.tokens,
            [
                .word("Pack"),
                .word("towel"),
                .project("travel"),
            ]
        )
    }

    func testInvalidProjects() {
        let line = "Pack 2+2 towels"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(
            item.tokens,
            [
                .word("Pack"),
                .word("2+2"),
                .word("towels"),
            ]
        )
    }

    func testKeyValueToken() {
        let line = "Pack towel due:tomorrow"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(
            item.tokens,
            [
                .word("Pack"),
                .word("towel"),
                .keyValue(key: "due", value: "tomorrow"),
            ]
        )
    }

    func testInvalidKeyValueTokens() {
        let line = "Todo: Pack towel :now"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(
            item.tokens,
            [
                .word("Todo:"),
                .word("Pack"),
                .word("towel"),
                .word(":now"),
            ]
        )
    }

    func testAmbigiousTokens() {
        let line = "Todo: Pack towel :now"
        let item = TodoParser.parse(line: line)

        XCTAssertFalse(item.completed)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.completionDate)
        XCTAssertNil(item.creationDate)
        XCTAssertEqual(
            item.tokens,
            [
                .word("Todo:"),
                .word("Pack"),
                .word("towel"),
                .word(":now"),
            ]
        )
    }

}
