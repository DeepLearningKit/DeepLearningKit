//
//  DeepLearningKitTests.swift
//  DeepLearningKitTests
//
//  Created by Rafael Almeida on 20/06/16.
//  Copyright © 2016 DeepLearningKit. All rights reserved.
//

import XCTest
@testable import DeepLearningKit

class DeepLearningKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let deepNetwork = DeepNetwork()
        XCTAssertNotNil(deepNetwork)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
