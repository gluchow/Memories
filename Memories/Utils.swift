import Foundation

class Utils {
    static let dateFormat = "dd.MM.yyyy"
    
    static func dateString(date: NSDate?) -> String? {
        if let date = date {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = dateFormat
            return dateFormatter.stringFromDate(date)
        }
        return nil
    }

}