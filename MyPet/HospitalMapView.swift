import SwiftUI
import MapKit
import Firebase
import FirebaseStorage
import FirebaseFirestore


struct HospitalMapView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: locationManager.nearbyHospitals) { hospital in
                MapMarker(coordinate: hospital.coordinate, tint: .red)
            }
            .frame(height: 300)
            .cornerRadius(10)
            .padding()

            Text("내 주변 동물병원")
                .font(.title2)
                .bold()
                .padding(.bottom, 4)

            List(locationManager.nearbyHospitals) { hospital in
                VStack(alignment: .leading, spacing: 4) {
                    Text(hospital.name)
                        .font(.headline)

                    Text(hospital.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if hospital.phoneNumber != "번호 없음" {
                        Button(action: {
                            callNumber(hospital.phoneNumber)
                        }) {
                            Text("📞 \(hospital.phoneNumber)")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text("전화번호: 없음")
                            .foregroundColor(.secondary)
                    }

                    Text(hospital.distanceText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func callNumber(_ number: String) {
        let tel = number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        if let url = URL(string: "tel://\(tel)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

