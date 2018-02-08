//
//  StringExtensions.swift
//  Exchange
//
//  Created by t.galimov on 30/01/2018.
//

import Foundation

extension String {

    func countOccurences(from characterSet: CharacterSet) -> Int {
        var stringToScan = self
        var count = 0
        while let foundRange = stringToScan.rangeOfCharacter(from: characterSet) {
            stringToScan = stringToScan.replacingCharacters(in: foundRange, with: "")
            count += 1
        }
        return count
    }
    
    /// Returns `nil` if `self` doesn't contain any of
    /// the characters from `characterSet`.
    func positionOfFirstCharacter(from characterSet: CharacterSet) -> Int? {
        guard let range = rangeOfCharacter(from: characterSet) else { return nil }
        return distance(from: startIndex, to: range.lowerBound)
    }
}
