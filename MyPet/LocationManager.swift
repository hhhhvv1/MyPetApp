import Foundation
import CoreLocation
import MapKit
import Firebase
import FirebaseStorage
import FirebaseFirestore


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // 기본값 (서울시청)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @Published var nearbyHospitals: [HospitalLocation] = []

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate

        DispatchQueue.main.async {
            self.region.center = coordinate
            self.searchNearbyHospitals()
        }
    }

    func searchNearbyHospitals() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "동물병원"
        request.region = MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.nearbyHospitals = response.mapItems.map {
                        HospitalLocation(mapItem: $0, userLocation: self.region.center)
                    }
                }
            } else if let error = error {
                print("병원 검색 오류: \(error.localizedDescription)")
            }
        }
    }
}

