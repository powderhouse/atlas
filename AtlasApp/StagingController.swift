//
//  StagingController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/15/18.
//

import Cocoa
import AtlasCore

class StagingController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    var atlasCore: AtlasCore!
    
    @IBOutlet weak var projectListView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureProjectListView()
        initObservers()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func resize(_ sender: NSButton) {
        if let panels = self.parent as? NSSplitViewController {
            if let main = panels.parent {
                let newPosition = main.view.frame.width * 0.8
                panels.splitView.setPosition(newPosition, ofDividerAt: 0)
            }
        }
    }
    
    func addProject(_ projectName: String) {
        _ = atlasCore.initProject(projectName)
        _ = atlasCore.atlasCommit()
        projectListView.reloadData()
        Terminal.log("Added project: \(projectName)")
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let projects = atlasCore.projects()
        return projects.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectViewItem"),
            for: indexPath
        )

        guard let projectViewItem = item as? ProjectViewItem else {
            return item
        }
        
        projectViewItem.project = atlasCore.projects()[indexPath.item]

        projectViewItem.refresh()

        return projectViewItem
    }

    fileprivate func configureProjectListView() {
        projectListView.isSelectable = true
        let flowLayout = NSCollectionViewFlowLayout()
        
        let projectHeight: CGFloat = 240
        let projectWidth: CGFloat = 240

        let bufferDim: CGFloat = 18
        
        flowLayout.itemSize = NSSize(width: projectWidth, height: projectHeight)
        flowLayout.sectionInset = NSEdgeInsets(top: bufferDim, left: bufferDim, bottom: bufferDim, right: bufferDim)
        flowLayout.minimumInteritemSpacing = bufferDim
        flowLayout.minimumLineSpacing = bufferDim
        projectListView.collectionViewLayout = flowLayout

        view.wantsLayer = true
        projectListView.setFrameSize(
            NSSize(
                width: view.frame.width,
                height: CGFloat(atlasCore.projects().count) * (projectHeight + (bufferDim * CGFloat(2)))
            )
        )
    }
    
    func initObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "project-added"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                self.addProject(projectName)
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "new-project-segue" {
            let dvc = segue.destinationController as! NewProjectController
            dvc.atlasCore = atlasCore
        }
    }

}
