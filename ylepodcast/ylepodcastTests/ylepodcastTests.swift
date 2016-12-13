//
//  ylepodcastTests.swift
//  ylepodcastTests
//
//  Created by Arto Heino on 28/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import XCTest
@testable import ylepodcast

class ylepodcastTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        func testSearchWithValidSearchString() {
            DatabaseController.clear(table: "Podcast")
            
            let context = DatabaseController.getContext()
            
            // Add one podcast to coredata with title "Kissa"
            let podcast1 = Podcast(context: context)
            podcast1.podcastTitle = "Kissa"
            
            // Add one podcast to coredata with title "Koira"
            let podcast2 = Podcast(context: context)
            podcast2.podcastTitle = "Koira"
            
            DatabaseController.saveContext()
            
            // Create SearchTableViewController
            let searchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Search") as! SearchTableViewController
            searchViewController.loadViewIfNeeded()
            
            // Scope 0 searches for title with search string "kissa"
            searchViewController.getData(scope: 0, searchString: "kissa")
            
            // Make sure we have one podcast visible in search results
            XCTAssertTrue(searchViewController.tableView.visibleCells.count == 1)
        }
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
