import Foundation

struct Storyboard {
    
    struct Segue {
        static let ShowNewTimeline = "Show New Timeline"
        static let ShowMoments = "Show Moments"
        static let ShowNewMoment = "Show New Moment"
        static let ShowMomentDetails = "Show Moment Details"
        static let ShowEditMoment = "Show Edit Moment"
        static let ShowMomentOnMap = "Show Moment On Map"
    }
    
    struct Identifier {
        static let TimelineTableCell = "Timeline Cell"
        static let MomentTableCell = "Moment Cell"
        static let MomentAnnotationViewReuseIdentifier = "Moment Annotation"
    }
}