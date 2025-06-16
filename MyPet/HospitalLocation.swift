import Foundation
import MapKit
import Firebase
import FirebaseStorage
import FirebaseFirestore


struct HospitalLocation: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    let userLocation: CLLocationCoordinate2D

    var name: String {
        mapItem.name ?? "이름 없음"
    }

    var coordinate: CLLocationCoordinate2D {
        mapItem.placemark.coordinate
    }

    var address: String {
        mapItem.placemark.title ?? ""
    }

    var phoneNumber: String {
        mapItem.phoneNumber ?? "번호 없음"
    }

    var distance: Double {
        let user = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let hospital = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return user.distance(from: hospital)
    }

    var distanceText: String {
        if distance >= 1000 {
            return String(format: "거리: %.2f km", distance / 1000)
        } else {
            return String(format: "거리: %.0f m", distance)
        }
    }
}

