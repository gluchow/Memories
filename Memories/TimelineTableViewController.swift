//
//  ViewController.swift
//  Memories
//
//  Created by admin on 11.05.16.
//  Copyright © 2016 gluglu. All rights reserved.
//

import UIKit

class TimelineTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var timelines = [Timeline]()
    
    
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: die echten Daten laden
        loadMockData()
    }
    
    private func loadMockData() {
        for i in 1..<4 {
            timelines.append(Timeline(name: "Timeline \(i)"))
        }
    }
    
    
    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // TODO
    }
    
    
    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Identifier.TimelineCell)

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Storyboard.Identifier.TimelineCell)
        }
        
        cell?.textLabel?.text = timelines[indexPath.row].name

        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return timelines.count
    }

}

