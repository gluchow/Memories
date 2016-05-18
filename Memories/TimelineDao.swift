import Foundation
import CoreData

// TODO oder über extension für Timeline?
class TimelineDao: BaseDao {
    
    func findAll() -> [Timeline]? {
        let fetchRequest = NSFetchRequest(entityName: Timeline.EntityName)
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            print("found \(result.count) timelines.")
            
            for timeline in (result as? [Timeline])! {
                print("Timeline has \(timeline.momentsArray.count)")
            }
            
            return result as? [Timeline]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func persistTimeline(forName name: String) -> (Timeline?, NSError?) {
        let timeline =  createEntity(forName: Timeline.EntityName) as! Timeline
        timeline.name = name
        timeline.creationDate = NSDate() // TODO anders lösen - evtl. init oder Ähnliches in der Entität
        
        do {
            try managedContext.save()
            print("Persisted timeline \(timeline).")
            return(timeline, nil)
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
            return(nil, error)
        }
        
    }
    
}