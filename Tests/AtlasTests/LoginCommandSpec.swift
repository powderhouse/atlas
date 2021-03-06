//
//  LoginCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 2/28/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class LoginCommandSpec: CliSpec {
    override func spec() {
        
        describe("Login") {
            
            let gitHubUser = "atlasapptests"
            let gitHubEmail = "atlasapptests@puzzleschool.com"
            let gitHubPassword = self.githubPassword
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            var isDirectory : ObjCBool = true
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            var loginCommand: LoginCommand!
            
            beforeEach {
                directory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ATLAS_CORE")
                
                Helper.deleteTestDirectory(directory)
                _ = FileSystem.createDirectory(directory)
                
                //                let filePath = directory.path
                //                let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory)
                //                expect(exists).to(beTrue(), description: "No folder found")
                
                atlasCore = AtlasCore(directory)
                loginCommand = LoginCommand(atlasCore)
                loginCommand.input.setDefaultInput(message: "GitHub Username:", response: gitHubUser)
                loginCommand.input.setDefaultInput(message: "GitHub Email:", response: gitHubEmail)
                loginCommand.input.setDefaultInput(message: "GitHub Password:", response: gitHubPassword!)
            }
            
            afterEach {
                Helper.deleteTestDirectory(directory)
            }
            
            
            context("execute") {
                
                beforeEach {
                    do {
                        try loginCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "LoginCommand failed")
                    }
                }
                
                it("should store the github credentials to the filesystem") {
                    let credentialsFile = directory.appendingPathComponent("credentials.json")
                    let exists = fileManager.fileExists(atPath: credentialsFile.path, isDirectory: &isFile)
                    expect(exists).to(beTrue(), description: "No credentials.json found")
                }
                
                it("saves a readme to the filesystem") {
                    if let readmeFile = atlasCore.appDirectory?.appendingPathComponent(Project.readme) {
                        let exists = fileManager.fileExists(atPath: readmeFile.path, isDirectory: &isFile)
                        expect(exists).to(beTrue(), description: "No readme.md found")
                    } else {
                        expect(false).to(beTrue(), description: "Atlas directory was not set")
                    }
                }
                
                it("sets atlasDirectory and creates the directory") {
                    if let atlasDirectory = atlasCore.appDirectory {
                        let exists = fileManager.fileExists(atPath: atlasDirectory.path, isDirectory: &isDirectory)
                        expect(exists).to(beTrue(), description: "atlasDirectory not found")
                    } else {
                        expect(false).to(beTrue(), description: "atlasDirectory not set")
                    }
                }
                
                it("initializes a General project") {
                    if let project = atlasCore.project("General") {
                        let projectPath = project.directory().path
                        let exists = fileManager.fileExists(atPath: projectPath, isDirectory: &isDirectory)
                        expect(exists).to(beTrue(), description: "General project directory not found")
                    } else {
                        expect(false).to(beTrue(), description: "General project does not exist")
                    }
                }
                
                context("future usage") {
                    var loginCommand: LoginCommand!
                    
                    beforeEach {
                        let atlasCore2 = AtlasCore(directory)
                        loginCommand = LoginCommand(atlasCore2)
                    }
                    
                    it("asks if you want to login again") {
                        let message = "You are already logged in as \(gitHubUser). Do you want to log in as someone else?"
                        loginCommand.input.setDefaultInput(message: message, response: "N")
                        
                        do {
                            try loginCommand.execute()
                        } catch {
                            expect(false).to(beTrue(), description: "LoginCommand failed")
                        }
                        
                        let credentialsFile = directory.appendingPathComponent("credentials.json")
                        let exists = fileManager.fileExists(atPath: credentialsFile.path, isDirectory: &isFile)
                        expect(exists).to(beTrue(), description: "No credentials.json found")
                    }
                }
            }
        }
    }
}
