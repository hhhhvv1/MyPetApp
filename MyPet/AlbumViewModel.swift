import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class AlbumViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var albumPhotos: [AlbumPhoto] = []
    @Published var selectedImage: UIImage? = nil
    @Published var commentText: String = ""
    @Published var isUploading = false
    @Published var userLocation: CLLocationCoordinate2D?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        fetchPhotos()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
    }

    func uploadPhoto(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser,
              let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(false)
            return
        }

        isUploading = true
        let uid = user.uid
        let imageID = UUID().uuidString
        let storageRef = storage.reference().child("users/\(uid)/albums/\(imageID).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("이미지 업로드 오류: \(error.localizedDescription)")
                self.isUploading = false
                completion(false)
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    self.isUploading = false
                    completion(false)
                    return
                }

                let docData: [String: Any] = [
                    "imageURL": downloadURL.absoluteString,
                    "comment": self.commentText,
                    "timestamp": Timestamp(date: Date()),
                    "latitude": self.userLocation?.latitude ?? 0.0,
                    "longitude": self.userLocation?.longitude ?? 0.0
                ]

                self.db.collection("users").document(uid).collection("albums").addDocument(data: docData) { error in
                    self.isUploading = false
                    if let error = error {
                        print("Firestore 저장 오류: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        self.commentText = ""
                        self.selectedImage = nil
                        print("✅ Firestore 저장 완료. fetchPhotos 호출.")
                        
                        // Firebase Storage 반영 시간 확보
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.fetchPhotos()
                        }

                        completion(true)
                    }
                }
            }
        }
    }

    func fetchPhotos() {
        guard let user = Auth.auth().currentUser else { return }

        db.collection("users").document(user.uid).collection("albums")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }

                var newPhotos: [AlbumPhoto] = []

                for doc in documents {
                    let data = doc.data()
                    let id = doc.documentID
                    let comment = data["comment"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp
                    let date = timestamp?.dateValue()
                    let lat = data["latitude"] as? CLLocationDegrees
                    let lon = data["longitude"] as? CLLocationDegrees
                    let location = (lat != nil && lon != nil) ? CLLocationCoordinate2D(latitude: lat!, longitude: lon!) : nil

                    if let urlString = data["imageURL"] as? String,
                       let url = URL(string: urlString),
                       let imageData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imageData) {
                        let photo = AlbumPhoto(id: id, image: uiImage, comment: comment, date: date, location: location)
                        newPhotos.append(photo)
                    }
                }

                DispatchQueue.main.async {
                    self.albumPhotos = newPhotos
                }
            }
    }
}

