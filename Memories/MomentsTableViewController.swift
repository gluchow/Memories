import UIKit

class MomentsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var moments = [Moment]()
    
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
            
            // TODO max. tableView.rowHeight?
            tableView.estimatedRowHeight = 150
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("MomentsTableViewController - viewWillAppear")

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
