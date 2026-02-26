//
//  SmartDateParserTests.swift
//  Tests
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Testing
import Foundation
@testable import ToDoList

struct SmartDateParserTests {
    let parser = SmartDateParser()

    @Test func basicDetectionWithTime() async throws {
        let result = parser.parse("Buy groceries tomorrow at 10am")
        #expect(result != nil)
        #expect(result?.cleanedContent == "Buy groceries")
        #expect(result?.hasTime == true)

        let expectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        let resultDate = result!.date
        #expect(Calendar.current.isDate(resultDate, inSameDayAs: expectedDate))
        #expect(Calendar.current.component(.hour, from: resultDate) == 10)
    }

    @Test func dateOnlyDetection() async throws {
        let result = parser.parse("Buy groceries tomorrow")
        #expect(result != nil)
        #expect(result?.cleanedContent == "Buy groceries")
        #expect(result?.hasTime == false)
    }

    @Test func dateAtBeginning() async throws {
        let result = parser.parse("Tomorrow buy milk")
        #expect(result != nil)
        #expect(result?.cleanedContent == "buy milk")
    }

    @Test func dateAtEndWithConnector() async throws {
        let result = parser.parse("Meeting on Friday at 3pm")
        #expect(result != nil)
        // Should strip "on" connector and the date
        let cleaned = result?.cleanedContent ?? ""
        #expect(cleaned == "Meeting")
    }

    @Test func noDateReturnsNil() async throws {
        let result = parser.parse("Buy groceries")
        #expect(result == nil)
    }

    @Test func emptyStringReturnsNil() async throws {
        let result = parser.parse("")
        #expect(result == nil)
    }

    @Test func fullDateOnlyInputReturnsNil() async throws {
        // When the entire input is a date, cleaned content would be empty → nil
        let result = parser.parse("tomorrow at 10am")
        #expect(result == nil)
    }

    @Test func hasTimeForSpecificTime() async throws {
        let result = parser.parse("Call dentist tomorrow at 2:30pm")
        #expect(result != nil)
        #expect(result?.hasTime == true)

        let hour = Calendar.current.component(.hour, from: result!.date)
        #expect(hour == 14)
    }

    @Test func hasTimeFalseForDateOnly() async throws {
        let result = parser.parse("Submit report next Friday")
        #expect(result != nil)
        #expect(result?.hasTime == false)
    }
}
