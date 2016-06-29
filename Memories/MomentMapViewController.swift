import UIKit
import MapKit
import CoreLocation

class MomentMapViewController: UIViewController, MKMapViewDelegate {
    var moment: Moment?
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Standard
            mapView.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        if moment != nil && moment!.hasCoordinates() {
            self.mapView.addAnnotation(self.moment!)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("viewForAnnotation")
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(Storyboard.Identifier.MomentAnnotationViewReuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Storyboard.Identifier.MomentAnnotationViewReuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        mapView.showAnnotations([annotation], animated: true)

        return annotationView
    }
    
}
