import Foundation
import FirebaseAuth

class AppViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil

    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }
}

