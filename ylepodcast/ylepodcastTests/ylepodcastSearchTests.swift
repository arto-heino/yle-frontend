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
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test search with valid scope and search string
    
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
    
    // Test search with invalid search string
    
    func testSearchWithInvalidSearchString() {
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
        
        // Scope 0 searches for title with search string "kani"
        searchViewController.getData(scope: 0, searchString: "kani")
        
        // Make sure we have zero podcast visible in search results
        XCTAssertTrue(searchViewController.tableView.visibleCells.count == 0)
    }
    
    // Test search with 2 valid search strings
    
    func testSearchWithInvalidSearchScope() {
        DatabaseController.clear(table: "Podcast")
        
        let context = DatabaseController.getContext()
        
        // Add one podcast to coredata with title "Kissa" and description "Kissalla on korvat, kissa ei ole koira"
        let podcast1 = Podcast(context: context)
        podcast1.podcastCollection = "Kissa"
        podcast1.podcastDescription = "Kissalla on korvat, kissa ei ole koira"
        
        // Add one podcast to coredata with title "Koira" and description "Kissalla on korvat, koira ei ole kissa"
        let podcast2 = Podcast(context: context)
        podcast2.podcastCollection = "Koira"
        podcast2.podcastDescription = "Koiralla on korvat, koira ei ole kissa"
        
        DatabaseController.saveContext()
        
        // Create SearchTableViewController
        let searchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Search") as! SearchTableViewController
        searchViewController.loadViewIfNeeded()
        
        // Scope 0 searches for all with search string "kissa"
        searchViewController.getData(scope: 0, searchString: "kissa")
        
        // Make sure we have two podcast visible in search results
        XCTAssertTrue(searchViewController.tableView.visibleCells.count == 2)
    }
    
}
