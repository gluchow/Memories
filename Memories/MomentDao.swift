import Foundation
import CoreData

enum MomentError: ErrorType {
    case NameValidationError(message: String)
}

class MomentDao : BaseDao {
    typealias PersistMomentResponse = (moment: Moment?, error: NSError?)
    typealias DeleteMomentResponse = (success: Bool, error: NSError?)
     
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
    
    func delete(moment: Moment) -> DeleteMomentResponse {
        print("Deleting moment.")
        managedContext.deleteObject(moment)
        
        do {
            try managedContext.save()
            return(true, nil)
            
        } catch let error as NSError  {
            print("Could not delete moment: \(error), \(error.localizedDescription)")
            return(false, error)
        }
    }
    
    func createNewMomentEntity(forName name: String, withinTimeline timeline: Timeline) throws -> Moment {
        try ensureNameIsValid(name)
        
        let moment =  createEntity(forName: Moment.EntityName) as! Moment
        moment.name = name
        moment.creationDate = NSDate()
        moment.timeline = timeline
        return moment;
    }

    func persistMoment(forName name: String, withinTimeline timeline: Timeline) throws ->  PersistMomentResponse {
        let moment = try createNewMomentEntity(forName: name, withinTimeline: timeline)
        return persistMoment(moment)
    }
    
    func persistMoment(moment: Moment) ->  PersistMomentResponse {
        do {
            try managedContext.save()
            print("Persisted moment \(moment).")
            return(moment, nil)
            
        } catch let error as NSError  {
            print("Could not save moment: \(error), \(error.localizedDescription)")
            return(nil, error)
        }
    }
    
    private func ensureNameIsValid(name: String) throws {
        // alternatively using guard
        // remove white space chars and check size:
        if name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters.count < 3 {
            throw MomentError.NameValidationError(message: "Name must have at least 3 characters.")
        }
    }
    
}