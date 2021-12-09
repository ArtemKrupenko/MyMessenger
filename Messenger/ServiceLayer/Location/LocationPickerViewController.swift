import UIKit
import CoreLocation
import MapKit

final class LocationPickerViewController: UIViewController {

    // MARK: - Properties
    public var completion: ((CLLocationCoordinate2D) -> Void)?

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()
    
    // MARK: - Dependencies
    private var coordinates: CLLocationCoordinate2D?
    private var isPickable = true

    init(coordinates: CLLocationCoordinate2D?) {
        self.coordinates = coordinates
        self.isPickable = coordinates == nil
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendButtonTapped))
            mapView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            mapView.addGestureRecognizer(gesture)
            // определяем геолокацию пользователя и масштабируем карту на регион пользователя
            LocationManager.shared.getUserLocation { [weak self] location in
                DispatchQueue.main.async {
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
                }
            }
        } else {
            // показываем местоположение
            guard let coordinates = self.coordinates else {
                return
            }
            let viewRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(viewRegion, animated: false)
            // ставим метку в указанном местоположении
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            mapView.addAnnotation(pin)
        }
        view.addSubview(mapView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }

    // MARK: - Functions
    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }

    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: mapView)
        let coordinates = mapView.convert(locationInView, toCoordinateFrom: mapView)
        self.coordinates = coordinates
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        // ставим метку в указанном местоположении
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
    }
}
