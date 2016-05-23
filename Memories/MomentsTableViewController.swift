import UIKit

class MomentsTableViewController: UITableViewController {
    
    private var moments = [Moment]()
    
    var timeline: Timeline? {
        didSet {
            moments.removeAll()
            if timeline != nil {
                moments = timeline!.momentsArray
            }
            reloadUI()
        }
    }

    // TODO prüfen, wie didSet überschrieben wird. Evtl. müssen delegates manuell gesetzt werden.
//    override var tableView: UITableView! {
//        didSet {
//            super.tableView.estimatedRowHeight = 200
//            super.tableView.rowHeight = UITableViewAutomaticDimension;
//        }
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        moments.removeAll()
        reloadUI()
    }
 
    private func reloadUI() {
        // TODO main thread?
        if let loadedMoments = MomentDao().findAll(forTimeline: timeline!) {
            moments = loadedMoments
        }
        
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != nil {
          
            switch(segue.identifier!) {
            case Storyboard.Segue.ShowNewMoment:
                let newMomentViewController = segue.destinationViewController as! NewMomentViewController
                newMomentViewController.timeline = timeline
                
            case Storyboard.Segue.ShowMomentDetails:
                let momentDetailsViewController = segue.destinationViewController as! MomentDetailsViewController
                let momentTableCell = sender as? MomentTableViewCell
                let moment = momentTableCell?.moment
                momentDetailsViewController.moment = moment
                
            default: break // nothing
            }
            
        }
       
    }
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Identifier.MomentTableCell) as? MomentTableViewCell
        
        if cell == nil {
            cell = MomentTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Storyboard.Identifier.MomentTableCell)
        }

        cell?.moment = moments[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return moments.count
    }
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITableViewDelegate
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
//    {
//        let moment = moments[indexPath.row]
//        performSegueWithIdentifier(Storyboard.Segue.ShowMomentDetails, sender: moment)
//    }
    
}
