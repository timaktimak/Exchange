//
//  NetworkClientTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 27/01/2018.
//

import XCTest
@testable import Exchange

class NetworkClientTest: XCTestCase {

    func testRequest() {
        let client = NetworkClient()
        let expectation = XCTestExpectation()
        client.get("https://jsonplaceholder.typicode.com/posts/1") { (data, error) in
            XCTAssert(error == nil)
            XCTAssert(data != nil)
            XCTAssert(data!.count > 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}
