import XCTest
@testable import SDIOS

final class DateUtilsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Her testten önce dili sıfırla (eğer gerekliyse)
        LanguagePreferences.shared.selectedLanguage = "tr"
    }

    func testFormatDateString() {
        let isoDate = "2024-03-20T10:00:00Z"
        let displayDate = DateUtils.formatDate(isoDate)
        // Not: Display format locale'e göre değişebilir, selectedLanguage = "tr" iken "20 Mar 2024" beklenir
        XCTAssert(displayDate.contains("Mar") || displayDate.contains("2024"))
        
        let simpleDate = "2024-03-20"
        let displaySimple = DateUtils.formatDate(simpleDate)
        XCTAssert(displaySimple.contains("2024"))
    }
    
    func testCalculateDaysRemaining() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let formatter = ISO8601DateFormatter()
        let tomorrowISO = formatter.string(from: tomorrow)
        
        let remaining = DateUtils.calculateDaysRemaining(tomorrowISO)
        XCTAssertEqual(remaining, 1)
        
        let invalidDate = "invalid"
        XCTAssertEqual(DateUtils.calculateDaysRemaining(invalidDate), -1)
    }
    
    func testFormatTurkishDay() {
        XCTAssertEqual(DateUtils.formatTurkishDay(1), "1'i")
        XCTAssertEqual(DateUtils.formatTurkishDay(2), "2'si")
        XCTAssertEqual(DateUtils.formatTurkishDay(3), "3'ü")
        XCTAssertEqual(DateUtils.formatTurkishDay(6), "6'sı")
        XCTAssertEqual(DateUtils.formatTurkishDay(9), "9'u")
        XCTAssertEqual(DateUtils.formatTurkishDay(10), "10'u")
        XCTAssertEqual(DateUtils.formatTurkishDay(20), "20'si")
        XCTAssertEqual(DateUtils.formatTurkishDay(30), "30'u")
    }
    
    func testFormatDayWithSuffix() {
        // English suffixes
        XCTAssertEqual(DateUtils.formatDayWithSuffix(day: 1, language: "en"), "1st")
        XCTAssertEqual(DateUtils.formatDayWithSuffix(day: 2, language: "en"), "2nd")
        XCTAssertEqual(DateUtils.formatDayWithSuffix(day: 3, language: "en"), "3rd")
        XCTAssertEqual(DateUtils.formatDayWithSuffix(day: 4, language: "en"), "4th")
        XCTAssertEqual(DateUtils.formatDayWithSuffix(day: 11, language: "en"), "11th")
        
        // Turkish
        XCTAssertEqual(DateUtils.formatDayWithSuffix(day: 1, language: "tr"), "1'i")
    }
}
