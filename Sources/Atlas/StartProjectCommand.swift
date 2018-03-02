//
//  StartProjectCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/16/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class StartProjectCommand: Command {
    
    var atlasCore: AtlasCore
    
    let name = "start"
    let shortDescription = "Start a new Atlas project."
    
    let project = Parameter()

    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        if atlasCore.initProject(project.value) {
            print("Project Started: \(project.value)")
            atlasCore.atlasCommit("\(name) Project Initialization")
        } else {
            print("There was an error creating this project.")
        }
    }
}
