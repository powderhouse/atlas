//
//  StressTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 11/4/18.
//

import XCTest

class StressTest: AtlasUITestCase {
    let project = "General"
    let project1 = "Test"
    let project2 = "AnotherTest"
    let commitMessage1 = "This is a stress test commit"
    let commitMessage2 = "This is another stress test commit"
    var path: String?
    
    override func setUp() {
        super.setUp()
        
        login(app)
    }
    
    func stageNoWait(_ filename: String, in projectName: String) {
        if path == nil {
            path = terminalOutput("pwd")
        }
        
        if let path = path {
            _ = terminalOutput("mkfile -n 10m ../\(filename)")
            _ = terminalOutput("stage -f \(path)/../\(filename) -p \(projectName)")
        }
    }
    
    func commitNoWait(_ projectName: String, commitMessage: String) {
        let projectStaged = app.groups["\(projectName)-staged"]
        projectStaged.buttons["Commit"].click()
        
        let commitDialog = projectStaged.popovers.firstMatch
        let commitMessageArea = commitDialog.textFields["Why are you submitting these files?"]
        commitMessageArea.click()
        commitMessageArea.typeText(commitMessage)
        commitDialog.buttons["Commit"].click()
    }
    
    func addProjectNoWait(_ projectName: String) {
        let splitGroupsQuery = app.splitGroups
        splitGroupsQuery.children(matching: .scrollView).element(boundBy: 0).children(matching: .collectionView).element.click()
        splitGroupsQuery.children(matching: .button)["+"].click()

        let projectTextField = app.popovers.textFields["Project Name"]
        XCTAssert(waitForElementToAppear(projectTextField))
        projectTextField.typeText(projectName)
        app.popovers.buttons["Save"].click()
        
        var tries = 0
        while tries < 10 && terminalOutput("ls \(projectName)/staged").contains("No such file or directory") {
            sleep(1)
            tries += 1
        }
    }
    
    func terminalOutput(_ command: String) -> String {
        let terminal = app.textFields["TerminalInput"]
        terminal.click()
        terminal.typeText("\(command)\n")
        if let output = app.textViews["TerminalView"].value as? String {
            if let message = output.components(separatedBy: "\n").last {
                return message
            }
        }
        return ""
    }
    
    func filename(_ projectName: String, index: Int) -> String {
        return "index\(index)\(projectName).html"
    }
    
    func stagedFile(_ project: String, name: String) -> XCUIElement {
        let stagingArea = app.collectionViews["\(project)-staged-files"]
        return stagingArea.groups[name]
    }
    
    func testInAStressfulManner() {
        let log = app.collectionViews["LogView"]
        
        for i in 0..<5 {
            stageNoWait(filename(project, index: i), in: project)
        }

        let generalFile0 = stagedFile(project, name: filename(project, index: 0))
        generalFile0.buttons["-"].firstMatch.click()
        clickAlertButton("Remove")
        
        addProjectNoWait(project1)
        
        for i in 0..<5 {
            stageNoWait(filename(project1, index: i), in: project1)
        }
        
        let stagedFile0 = stagedFile(project1, name: filename(project1, index: 0))
        stagedFile0.children(matching: .checkBox).firstMatch.click()

        let stagedFile1 = stagedFile(project1, name: filename(project1, index: 1))
        stagedFile1.children(matching: .checkBox).firstMatch.click()
        
        stagedFile0.buttons["-"].firstMatch.click()
        clickAlertButton("Remove")
        
        commitNoWait(project1, commitMessage: commitMessage1)
        
        addProjectNoWait(project2)
        
        for i in 0..<5 {
            stageNoWait(filename(project2, index: i), in: project2)
        }
        commitNoWait(project2, commitMessage: commitMessage2)
        
        for i in 5..<10 {
            stageNoWait(filename(project2, index: i), in: project2)
        }
        
        XCTAssert(waitForElementToAppear(app.groups["\(project2)-staged"].buttons["x"]))
        app.groups["\(project2)-staged"].buttons["x"].click()
        
        XCTAssert(waitForElementToAppear(app.buttons.matching(identifier: "Delete").firstMatch))
        clickAlertButton("Delete")
        
        XCTAssert(waitForElementToDisappear(app.collectionViews["\(project2)-staged-files"]))
        
        let generalStagingArea = app.collectionViews["\(project)-staged-files"]
        XCTAssert(!generalStagingArea.staticTexts[filename(project, index: 0)].exists)
        XCTAssert(generalStagingArea.staticTexts[filename(project, index: 1)].exists)
        
        let testStagingArea = app.collectionViews["\(project1)-staged-files"]
        XCTAssert(!testStagingArea.staticTexts[filename(project1, index: 0)].exists)
        XCTAssert(testStagingArea.staticTexts[filename(project1, index: 1)].exists)
        
        for i in 2..<4 {
            XCTAssert(!testStagingArea.staticTexts[filename(project1, index: i)].exists, "Found \(i)")
        }
        
        XCTAssert(log.staticTexts[commitMessage1].exists, "Unable to find \(commitMessage1)")
        XCTAssert(log.staticTexts[project1].exists)
        for i in 2..<4 {
            XCTAssert(log.links[filename(project1, index: i)].exists, "Can't find \(i)")
        }
        
        XCTAssert(!log.staticTexts[commitMessage2].exists, "Still found \(commitMessage2)")
        XCTAssert(!log.staticTexts[project2].exists)
        for i in 0..<5 {
            XCTAssert(!log.links[filename(project2, index: i)].exists)
        }
    }
}


