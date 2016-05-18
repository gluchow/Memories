import UIKit

class MomentsTableViewController: UITableViewController {
    var timeline: Timeline? {
        didSet {
            moments.removeAll()
            if timeline != nil {
                moments = timeline!.momentsArray
            }
            reloadUI()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        moments.removeAll()
        reloadUI()
    }
    
    private var moments = [Moment]()
    
    private func reloadUI() {
        // TODO main thread?
        if let loadedMoments = MomentDao().findAll(forTimeline: timeline!) {
            moments = loadedMoments
        }
        
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == Storyboard.Segue.ShowNewMoment) {
            let newMomentViewController = segue.destinationViewController as! NewMomentViewController
            newMomentViewController.timeline = timeline
        }
    }
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Identifier.MomentTableCell)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Storyboard.Identifier.MomentTableCell)
        }
        
        // TODO eigenen Celltype
        cell?.textLabel?.text = moments[indexPath.row].name
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return moments.count
    }
    
}
