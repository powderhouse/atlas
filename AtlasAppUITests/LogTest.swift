//
//  LogTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 4/19/18.
//

import XCTest

class LogTest: AtlasUITestCase {
    
    func testProjectFilter() {
        login(app)
        
        waitForTerminalToContain("Added project: General")
        
        let projectName = "Project"
        app.buttons["+"].click()
        let projectTextField = app.popovers.textFields["Project Name"]
        projectTextField.typeText(projectName)
        app.popovers.buttons["Save"].click()

        let filename = "indexfile.html"
        let commitMessage = "I am committing these files because I want to."
        stage(app, projectName: projectName, filename: filename)
        
        let projectStaged = app.groups["Project-staged"]
        projectStaged.buttons["Commit"].click()
        
        let commitDialog = projectStaged.popovers.firstMatch
        let commitMessageArea = commitDialog.textFields["Why are you submitting these files?"]
        commitMessageArea.click()
        commitMessageArea.typeText(commitMessage)
        commitDialog.buttons["Commit"].click()
        
        waitForTerminalToContain("Files successfully committed.")

        app.buttons["<"].click()
        
        let log = app.collectionViews["LogView"]
        XCTAssert(log.staticTexts["\(commitMessage)\n"].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.links[filename].exists, "Unable to find \(filename) link")
     
        app.buttons["General"].click()
        waitForTerminalToContain("Filtering for General")
        XCTAssertFalse(log.staticTexts["\(commitMessage)\n"].exists, "Still found \(commitMessage)")
        XCTAssertFalse(log.staticTexts[projectName].exists, "Still found \(projectName)")
        XCTAssertFalse(log.links[filename].exists, "Still found \(filename) link")

        app.buttons["General"].click()
        waitForTerminalToContain("Removing filter for General")
        XCTAssert(log.staticTexts["\(commitMessage)\n"].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.links[filename].exists, "Unable to find \(filename) link")

        app.buttons[projectName].click()
        waitForTerminalToContain("Filtering for \(projectName)")
        XCTAssert(log.staticTexts["\(commitMessage)\n"].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.links[filename].exists, "Unable to find \(filename) link")
        
        app.buttons["General"].click()
        waitForTerminalToContain("Filtering for General")
        XCTAssertFalse(log.staticTexts["\(commitMessage)\n"].exists, "Still found \(commitMessage)")
        XCTAssertFalse(log.staticTexts[projectName].exists, "Still found \(projectName)")
        XCTAssertFalse(log.links[filename].exists, "Still found \(filename) link")
    }
    
}
