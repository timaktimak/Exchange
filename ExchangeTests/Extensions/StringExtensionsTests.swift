//
//  StringExtensionsTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 05/02/2018.
//

import XCTest
@testable import Exchange

class StringExtensionsTests: XCTestCase {
    
    func testCountOccurencesFrom() {
        do {
            let characterSet = CharacterSet(charactersIn: "")
            XCTAssertEqual(0, "abcdefghi1234567890".countOccurences(from: characterSet))
        }
        do {
            let characterSet = CharacterSet().inverted
            XCTAssertEqual(0, "".countOccurences(from: characterSet))
        }
        do {
            let characterSet = CharacterSet(charactersIn: "0")
            XCTAssertEqual(6, "000000".countOccurences(from: characterSet))
        }
        do {
            let characterSet = CharacterSet(charactersIn: "012")
            XCTAssertEqual(6, "011222".countOccurences(from: characterSet))
        }
        do {
            let characterSet = CharacterSet(charactersIn: "3")
            XCTAssertEqual(1, "123456".countOccurences(from: characterSet))
        }
    }
    
    func testPositionOfFirstCharacterFrom() {
        do {
            let characterSet = CharacterSet(charactersIn: "")
            XCTAssertEqual(nil, "123456".positionOfFirstCharacter(from: characterSet))
        }
        do {
            let characterSet = CharacterSet().inverted
            XCTAssertEqual(nil, "".positionOfFirstCharacter(from: characterSet))
        }
        do {
            let characterSet = CharacterSet(charactersIn: "ab")
            XCTAssertEqual(3, "000babab".positionOfFirstCharacter(from: characterSet))
        }
        do {
            let characterSet = CharacterSet(charactersIn: "_")
            XCTAssertEqual(10, "0123456789_".positionOfFirstCharacter(from: characterSet))
        }
        do {
            let characterSet = CharacterSet.alphanumerics
            XCTAssertEqual(0, "0123456789_".positionOfFirstCharacter(from: characterSet))
        }
    }
}
