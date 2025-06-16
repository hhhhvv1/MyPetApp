import Foundation
import CoreLocation
import SwiftUI

struct AlbumPhoto: Identifiable {
    let id: String
    let image: UIImage?
    let comment: String
    let date: Date?
    let location: CLLocationCoordinate2D?
}

