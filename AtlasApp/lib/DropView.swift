//
//  DropView.swift
//  atlas
//
//  Created by Jared Cosulich on 12/10/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore

class DropView: NSView {
    
    var filePath: String?
    var project: Project?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.layer?.backgroundColor = NSColor.green.cgColor
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0).cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0).cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let paths = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? [String]
            else { return false }
        
        guard project != nil else { return false }
        
        DispatchQueue.global(qos: .background).async {
            let result = self.project!.copyInto(paths)
            if result.success {
                DispatchQueue.main.async(execute: {
                    Terminal.log("Imported files into \(self.project!.name!)")
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "file-updated"),
                        object: nil,
                        userInfo: ["projectName": self.project!.name!]
                    )
                })
            }
        }
        return true
    }
}
