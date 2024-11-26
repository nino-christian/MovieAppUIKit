//
//  CoreDataStack_Tests.swift
//  MovieAppUIKitTests
//
//  Created by Niño Christian Amahan on 11/25/24.
//

import XCTest
import CoreData
@testable import MovieAppUIKit

final class CoreDataStack_Tests: XCTestCase {

    var sut: CoreDataStack!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = CoreDataStack.testInstance()
        super.setUp()
       
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
       
    }

    func test_CoreDataStack_testInMemoryStore() {
        
        let storeType = sut.persistentContainer.persistentStoreDescriptions.first?.type
        XCTAssertEqual(storeType, NSInMemoryStoreType)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
