//
//  SmartDateParser.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation

struct SmartDateParser {
    struct Result {
        let cleanedContent: String
        let date: Date
        let hasTime: Bool
        let matchedText: String
    }

    private static let detector: NSDataDetector? = {
        try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
    }()

    private static let danglingConnectors = try! NSRegularExpression(
        pattern: #"(?:^|\s)\b(?:on|at|by|for)\b\s*$"#,
        options: [.caseInsensitive]
    )

    private static let leadingConnectors = try! NSRegularExpression(
        pattern: #"^\s*\b(?:on|at|by|for)\b(?:\s|$)"#,
        options: [.caseInsensitive]
    )

    func parse(_ text: String) -> Result? {
        guard !text.isEmpty, let detector = Self.detector else { return nil }

        let range = NSRange(text.startIndex..., in: text)
        let matches = detector.matches(in: text, options: [], range: range)

        guard let match = matches.first, let parsedDate = match.date else { return nil }

        let matchRange = Range(match.range, in: text)!
        let matchedText = String(text[matchRange])

        // Reject if match covers >80% of text
        let matchRatio = Double(matchedText.count) / Double(text.count)
        if matchRatio > 0.8 { return nil }

        // Reject past dates more than 7 days ago
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        if parsedDate < sevenDaysAgo { return nil }

        // Clean content: remove the matched date range
        var cleaned = text
        cleaned.removeSubrange(matchRange)

        // Remove dangling connectors at the end
        let cleanedNS = cleaned as NSString
        let cleanedRange = NSRange(location: 0, length: cleanedNS.length)
        cleaned = Self.danglingConnectors.stringByReplacingMatches(
            in: cleaned, options: [], range: cleanedRange, withTemplate: ""
        )

        // Remove leading connectors at the start
        let updatedNS = cleaned as NSString
        let updatedRange = NSRange(location: 0, length: updatedNS.length)
        cleaned = Self.leadingConnectors.stringByReplacingMatches(
            in: cleaned, options: [], range: updatedRange, withTemplate: ""
        )

        // Collapse whitespace and trim
        cleaned = cleaned.replacingOccurrences(
            of: #"\s+"#, with: " ", options: .regularExpression
        ).trimmingCharacters(in: .whitespacesAndNewlines)

        // Reject if cleaned content is empty
        if cleaned.isEmpty { return nil }

        // Determine hasTime
        let hasTime = detectHasTime(date: parsedDate, matchedText: matchedText)

        return Result(
            cleanedContent: cleaned,
            date: hasTime ? parsedDate : Calendar.current.startOfDay(for: parsedDate),
            hasTime: hasTime,
            matchedText: matchedText
        )
    }

    private static let timeIndicators = try! NSRegularExpression(
        pattern: #"(?:\d{1,2}:\d{2}|\d{1,2}\s*(?:am|pm|a\.m\.|p\.m\.)|noon|midnight|morning|evening|night|afternoon)"#,
        options: [.caseInsensitive]
    )

    private func detectHasTime(date: Date, matchedText: String) -> Bool {
        let range = NSRange(matchedText.startIndex..., in: matchedText)
        return Self.timeIndicators.firstMatch(in: matchedText, options: [], range: range) != nil
    }
}
