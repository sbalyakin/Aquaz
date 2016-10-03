//
//  AquazUITests.swift
//  AquazUITests
//
//  Created by Sergey Balyakin on 29.11.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import XCTest

class SnapshotUITests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    let app = XCUIApplication()
    setLanguage(app)
    app.launch()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSnapshot() {
    
    let app = XCUIApplication()
    snapshot("1-Drinks")
    
    app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Water").children(matching: .other).element(boundBy: 1).tap()
    snapshot("4-Intake")
    
    app.navigationBars["Aquaz.IntakeView"].buttons["Cancel"].tap()
    
    let tabBarsQuery = app.tabBars
    tabBarsQuery.buttons["Statistics"].tap()
    app.buttons["IconLeftActive"].tap()
    snapshot("5-Statistics")

    tabBarsQuery.buttons["Settings"].tap()
    
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Daily Water Intake"].tap()
    snapshot("2-WaterGoal")

    app.navigationBars["Daily Water Intake"].buttons["Cancel"].tap()
    tablesQuery.staticTexts["Notifications"].tap()
    snapshot("3-Notifications")
  }
  
}
