//
//  SettingsViewModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import AuthenticationServices
import CryptoKit
import GoogleSignIn

class SettingsViewModel: ObservableObject {
    @Published var user: UserModel? = nil
    
    @Published var showPasswordAlert: Bool = false
    @Published var passwordInput: String = ""
    
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "AppLanguage")
            Bundle.setLanguage(selectedLanguage)
            NotificationCenter.default.post(name: .languageChanged, object: nil) 
        }
    }
    
    var passwordContinuation: CheckedContinuation<String, Never>?
    let languageOptions = ["en", "tr"]
    
    init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            selectedLanguage = savedLanguage
        } else {
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            
            if preferredLanguage.starts(with: "tr") {
                selectedLanguage = "tr"
            } else {
                selectedLanguage = "en"
            }
            
            UserDefaults.standard.set(selectedLanguage, forKey: "AppLanguage")
        }
        
        Bundle.setLanguage(selectedLanguage)
    }
    
    func isPasswordLogin() -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        for info in user.providerData {
            if info.providerID == "password" {
                return true
            }
        }
        return false
    }
    
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching document: \(error.localizedDescription)")
                    return
                }
                guard let data = snapshot?.data() else {
                    print("Document data is nil")
                    return
                }
                print("Fetched data: \(data)")
                
                DispatchQueue.main.async {
                    self?.user = UserModel(
                        id: data["id"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        joined: data["joined"] as? Double ?? 0
                    )
                }
            }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
}

extension SettingsViewModel {
    func deleteAccount() async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        guard let lastSignInDate = user.metadata.lastSignInDate else { return false }
        let needsReauth = !lastSignInDate.isWithinPast(minutes: 5)
        
        do {
            if let providerID = user.providerData.first?.providerID {
                if providerID == "apple.com" {
                    try await reauthenticateWithApple(user: user, needsReauth: needsReauth)
                } else if providerID == "password" {
                    try await reauthenticateWithEmail(user: user)
                } else if providerID == "google.com" {
                    try await reauthenticateWithGoogle(user: user)
                }
            }
            try await deleteUserData(userId: user.uid)
            try await user.delete()
            print("User successfully deleted.")
            return true
        } catch {
            print("error")
            
        }
        return false
    }
    
    private func reauthenticateWithApple(user: User, needsReauth: Bool) async throws {
        
        
        let needsTokenRevocation = user.providerData.contains { $0.providerID == "apple.com" }
        
        let signInWithApple = await SignInWithApple()
        let appleIDCredential = try await signInWithApple()
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw NSError(domain: "Apple Reauth Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token."])
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "Apple Reauth Error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string."])
        }
        
        let nonce = randomNonceString()
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        if needsReauth {
            try await user.reauthenticate(with: credential)
        }
        
        if needsTokenRevocation {
            guard let authorizationCode = appleIDCredential.authorizationCode else {
                throw NSError(domain: "Apple Token Revocation Error", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch authorization code."])
            }
            
            guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
                throw NSError(domain: "Apple Token Revocation Error", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize authorization code."])
            }
            
            try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
            print("Apple token successfully revoked.")
        }
    }
    
    private func reauthenticateWithGoogle(user: User) async throws {
        guard let rootScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootWindow = await rootScene.windows.first,
              let rootViewController = await rootWindow.rootViewController else {
        throw NSError(domain: "Google Reauth Error", code: 4, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])
    }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "Google Reauth Error", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch Google ID token."])
        }
        
        let accessToken = result.user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        try await user.reauthenticate(with: credential)
        
        print("Reauthenticated with Google successfully.")
    }
    
      private func reauthenticateWithEmail(user: User) async throws {
          let password = await getPasswordFromAlert()

          guard !password.isEmpty else {
                 print("Error: Password is required for reauthentication.")
                 throw NSError(domain: "Reauth Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "Password cannot be empty."])
             }

             guard let email = user.email else {
                 throw NSError(domain: "Reauth Error", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email is unavailable."])
             }

             let credential = EmailAuthProvider.credential(withEmail: email, password: password)
             try await user.reauthenticate(with: credential)
             print("Reauthenticated successfully with Email/Password.")
      }
    
    private func getPasswordFromAlert() async -> String {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.showPasswordAlert = true
                self.passwordContinuation = continuation
            }
        }
    }
    
    private func deleteUserData(userId: String) async throws {
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(userId)
        
        let taskDocs = try await userDocRef.collection("tasks").getDocuments()
        for task in taskDocs.documents {
            try await task.reference.delete()
        }
        
        try await userDocRef.delete()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
}


// MARK: - Sign in with Apple

class SignInWithApple: NSObject, ASAuthorizationControllerDelegate {
    
    private var continuation : CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
    
    func callAsFunction() async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
            continuation?.resume(returning: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}
