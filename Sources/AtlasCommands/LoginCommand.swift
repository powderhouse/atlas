//
//  LoginCommand.swift
//  AtlasPackageDescription
//
//  Created by Jared Cosulich on 2/13/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class LoginCommand: Command {
    
    public var atlasCore: AtlasCore
    
    public let name = "login"
    public let shortDescription = "Login to Atlas using your GitHub credentials."
    
    public let usernameOption = Key<String>("-u", "--username", description: "Your GitHub username")
    public let emailOption = Key<String>("-e", "--email", description: "Your GitHub email")
    public let passwordOption = Key<String>("-p", "--password", description: "Your GitHub password")
    
    public var input: AtlasInput!
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
        self.input = AtlasInput()
    }
    
    public func execute() throws  {
        if let credentials = atlasCore.getCredentials() {
            let confirmLogin = "You are already logged in as \(credentials.username). Do you want to log in as someone else?"
            if !input.awaitYesNoInput(message: confirmLogin) {
                return
            }
        }
        
        var username = usernameOption.value
        if username == nil {
            username = input.awaitInput(message: "GitHub Username:")
        }
        
        var email = emailOption.value
        if email == nil {
            email = input.awaitInput(message: "GitHub Email:")
        }

        var password = passwordOption.value
        if password == nil {
            password = input.awaitInput(message: "GitHub Password:", secure: true)
        }
        
        guard username != nil else {
            print("Please provide a username using -u or --username (e.g. -u github_username)")
            return
        }

        guard email != nil else {
            print("Please provide an email using -e or --email (e.g. -e you@example.com)")
            return
        }

        guard password != nil else {
            print("Please provide a username using -p or --password (e.g. -p github_password)")
            return
        }
        
        let credentials = Credentials(username!, email: email!, password: password!)
        if atlasCore.initGitAndGitHub(credentials).success {
            print("Logged into Atlas as \(credentials.username)")
            if let repository = atlasCore.gitHubRepository() {
                print("GitHub Repository: \(repository)")
            }
            if let localRepository = atlasCore.appDirectory {
                print("Local repository: \(localRepository.path)")
            }
            
            _ = atlasCore.initProject("General")
            
            print(atlasCore.atlasCommit("Atlas Initialization").allMessages)
        } else {
            print("Error logging in.")
        }

    }
    
}
