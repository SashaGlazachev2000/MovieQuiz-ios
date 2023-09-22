import XCTest
@testable import MovieQuiz

class ArrayTest: XCTestCase {
    func testGetValueInRange() {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() {
        // Given
        let array = [1, 1, 2, 3 ,5]
        
        // When
        let value = array[safe: 23]
        
        // Then
        XCTAssertNil(value)
    }
}
