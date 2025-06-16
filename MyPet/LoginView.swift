import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseFirestore


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("이메일", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("비밀번호", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("로그인") {
                    login()
                }
                .buttonStyle(.borderedProminent)

                Button("회원가입") {
                    register()
                }
                .foregroundColor(.blue)
                
                Text(errorMessage)
                    .foregroundColor(.red)
                
                NavigationLink(destination: ContentView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("로그인")
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "로그인 오류: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
            }
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "회원가입 오류: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
            }
        }
    }
}

