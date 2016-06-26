import UIKit

class MomentsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var moments = [Moment]()
    
    private let timelineDao = TimelineDao()
    
    var timeline: Timeline? {
        didSet {
            if timeline != nil {
                moments = timeline!.momentsArray
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if tableView != nil {
            reloadUI()
        }
    }
    
    private func reloadUI() {
        moments.removeAll()
        
        if let loadedMoments = MomentDao().findAll(forTimeline: timeline!) {
            moments = loadedMoments
        }
        
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != nil {
          
            switch(segue.identifier!) {
            case Storyboard.Segue.ShowNewMoment:
                print("show new moment segue...")
                let momentViewController = segue.destinationViewController as! EditMomentTableViewController
                momentViewController.timeline = timeline
                
            case Storyboard.Segue.ShowMomentDetails:
                let momentDetailsViewController = segue.destinationViewController as! MomentDetailsViewController
                let momentTableCell = sender as? MomentTableViewCell
                let moment = momentTableCell?.moment
                momentDetailsViewController.moment = moment
                
            default: break // nothing
            }
            
        }
       
    }
    
    @IBAction func deleteTimeline(sender: UIBarButtonItem) {
        if timeline != nil {
            showRequestMessage("Do you really want to delete this timeline with all moments?", type: .Warning, actionHandler: { (action: UIAlertAction!) in
                let response = self.timelineDao.delete(self.timeline!)
                if response.error != nil {
                    self.showMessage("Timeline could not be deleted.", type: .Error)
                }
                
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Identifier.MomentTableCell) as? MomentTableViewCell
        
        if cell == nil {
            cell = MomentTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Storyboard.Identifier.MomentTableCell)
        }

        cell?.moment = moments[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return moments.count
    }
    
}
