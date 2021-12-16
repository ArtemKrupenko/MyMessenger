import UIKit
import CoreLocation
import MapKit

/// Определение локации пользователя
class LocationManager: NSObject, CLLocationManagerDelegate {

    // MARK: - Properties
    static let shared = LocationManager()
    public let manager = CLLocationManager()
    public var completion: ((CLLocation) -> Void)?

    public func getUserLocation(completion: @escaping ((CLLocation) -> Void)) {
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    // MARK: - Functions
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
}
