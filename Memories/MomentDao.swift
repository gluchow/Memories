import Foundation
import CoreData // TODO warum muss CoreData importiert werden, wenn die Basisklasse dies bereits macht?

class MomentDao : BaseDao {
    
    typealias PersistMomentResponse = (moment: Moment?, error: NSError?)
    
    func findAll(forTimeline timeline: Timeline) -> [Moment]? {
        let fetchRequest = NSFetchRequest(entityName: Moment.EntityName)
        fetchRequest.predicate = NSPredicate(format: "timeline == %@", timeline)
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            print("found \(result.count) moments.")
            return result as? [Moment]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func createNewMomentEntity(forName name: String, withinTimeline timeline: Timeline) -> Moment {
        let moment =  createEntity(forName: Moment.EntityName) as! Moment
        moment.name = name
        moment.creationDate = NSDate() // TODO anders lösen - evtl. init oder Ähnliches in der Entität
        moment.timeline = timeline
        return moment;
    }
    
    func persistMoment(forName name: String, withinTimeline timeline: Timeline) ->  PersistMomentResponse {
        let moment =  createNewMomentEntity(forName: name, withinTimeline: timeline)
        return persistMoment(moment)
    }
    
    func persistMoment(moment: Moment) ->  PersistMomentResponse {
        do {
            try managedContext.save()
            print("Persisted moment \(moment).")
            return(moment, nil)
            
        } catch let error as NSError  {
            print("Could not save Moment: \(error), \(error.userInfo)")
            return(nil, error)
        }
    }
    
    
}