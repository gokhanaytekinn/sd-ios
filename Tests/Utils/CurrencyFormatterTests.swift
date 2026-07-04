import XCTest
@testable import SDIOS

final class CurrencyFormatterTests: XCTestCase {
    
    func testFormatAmount() {
        // Test TR Lira
        let trResult = CurrencyFormatter.formatAmount(1234.56, currencyCode: 1)
        XCTAssertEqual(trResult, "1.234,56 ₺")
        
        // Test USD
        let usdResult = CurrencyFormatter.formatAmount(1234.56, currencyCode: 2)
        XCTAssertEqual(usdResult, "1.234,56 $")
        
        // Test EUR
        let eurResult = CurrencyFormatter.formatAmount(1234.56, currencyCode: 3)
        XCTAssertEqual(eurResult, "1.234,56 €")
    }
    
    func testFormatAmountLocalized() {
        let result = CurrencyFormatter.formatAmountLocalized(1234.56)
        XCTAssertEqual(result, "1.234,56")
        
        let zeroResult = CurrencyFormatter.formatAmountLocalized(0.0)
        XCTAssertEqual(zeroResult, "0,00")
    }
    
    func testGetCurrencySymbol() {
        XCTAssertEqual(CurrencyFormatter.getCurrencySymbol(1), "₺")
        XCTAssertEqual(CurrencyFormatter.getCurrencySymbol(2), "$")
        XCTAssertEqual(CurrencyFormatter.getCurrencySymbol(3), "€")
        XCTAssertEqual(CurrencyFormatter.getCurrencySymbol(4), "£")
        XCTAssertEqual(CurrencyFormatter.getCurrencySymbol(6), "₼")
        XCTAssertEqual(CurrencyFormatter.getCurrencySymbol(999), "₺") // Default case
    }
    
    func testParseBankingAmount() {
        XCTAssertEqual(CurrencyFormatter.parseBankingAmount("1.234,56"), 1234.56)
        XCTAssertEqual(CurrencyFormatter.parseBankingAmount("1234,56"), 1234.56)
        XCTAssertEqual(CurrencyFormatter.parseBankingAmount("1.000"), 1000.0)
        XCTAssertEqual(CurrencyFormatter.parseBankingAmount("invalid"), 0.0)
    }
}
