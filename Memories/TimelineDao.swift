import Foundation
import CoreData

// TODO oder über extension für Timeline?
class TimelineDao: BaseDao {
    
    typealias DeleteTimelineResponse = (success: Bool, error: NSError?)

    func findAll() -> [Timeline]? {
        let fetchRequest = NSFetchRequest(entityName: Timeline.EntityName)
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            print("found \(result.count) timelines.")
            
            for timeline in (result as? [Timeline])! {
                print("Timeline has \(timeline.momentsArray.count) moments.")
            }
            
            return result as? [Timeline]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func delete(timeline: Timeline) -> DeleteTimelineResponse {
        print("Deleting timeline.")
        managedContext.deleteObject(timeline)
        
        do {
            try managedContext.save()
            return(true, nil)
            
        } catch let error as NSError  {
            print("Could not delete timeline: \(error), \(error.userInfo)")
            return(false, error)
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