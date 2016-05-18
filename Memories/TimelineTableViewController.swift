//
//  ViewController.swift
//  Memories
//
//  Created by admin on 11.05.16.
//  Copyright © 2016 gluglu. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController {
    private var timelines = [Timeline]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        log("viewWillAppear")
        
        // TODO prüfen, ob es sinnvoll ist jedes Mal die Daten zu laden
        loadData()
    }
    
    private func loadData() {
        timelines.removeAll()
        if let result = TimelineDao().findAll() {
            timelines = result
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("viewDidLoad")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == Storyboard.Segue.ShowMoments) {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let timeline = timelines[indexPath.row]
                let momentsTableViewController = segue.destinationViewController as! MomentsTableViewController

                momentsTableViewController.timeline = timeline
            }
        }
    }

    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Identifier.TimelineTableCell)

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Storyboard.Identifier.TimelineTableCell)
        }
        
        // TODO eigenen Celltype
        cell?.textLabel?.text = timelines[indexPath.row].name

        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return timelines.count
    }
    
    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: helping functions
    private func log(text: String) {
        let currentClassType = NSStringFromClass(self.dynamicType)
        print("\(currentClassType) - \(text)")
    }

}

