//
//  SettingsViewModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

class SettingsViewModel: ObservableObject {
    @Published var user: UserModel? = nil
//    @Published var isLoggedIn: Bool = true
    @Published var selectedLanguage: String = "English"
    let languageOptions = ["English", "Türkçe"]
    
    init() {
        
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
    
    func deleteCurrentUser(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            print("Error: User is not logged in.")
            throw URLError(.badURL)
        }

        // settingsViewModel.user.email üzerinden mevcut email'i alın
        guard let email = self.user?.email, !email.isEmpty else {
            print("Error: Email not found.")
            throw URLError(.badURL)
        }

        do {
            // Yeniden doğrulama için kimlik bilgileri
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            try await user.reauthenticate(with: credential)
            print("Reauthentication successful")

            // Kullanıcıyı sil
            try await user.delete()
            print("User successfully deleted.")
        } catch let error as NSError {
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                print("Reauthentication required.")
            } else {
                print("Error deleting user: \(error.localizedDescription)")
            }
            throw error
        }
    }
    
}

extension SettingsViewModel {
    func deleteAccount() async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        guard let lastSignInDate = user.metadata.lastSignInDate else { return false }
        let needsReauth = !lastSignInDate.isWithinPast(minutes: 5)
        
        let needsTokenRevocation = user.providerData.contains { $0.providerID == "apple.com" }
        
        do {
            
            if needsReauth || needsTokenRevocation {
                let signInWithApple = SignInWithApple()
                let appleIDCredential = try await signInWithApple()
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetdch identify token.")
                    return false
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                    return false
                }
                let nonce = randomNonceString()
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                                idToken: idTokenString,
                                                                rawNonce: nonce)
                if needsReauth {
                         try await user.reauthenticate(with: credential)
                       }
                if needsTokenRevocation {
                          guard let authorizationCode = appleIDCredential.authorizationCode else { return false }
                          guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return false }

                          try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
                    let user = Auth.auth().currentUser

                    user?.delete { error in
                      if let error = error {
                        print("Error deleting user: \(error)")
                      } else {
                        print("User deleted successfully")
                      }
                    }
                        }
            }
            try await user.delete()
            print("errırrrr")
        } catch {
            print("errırrrr")
            
        }
        return false
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

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
}
extension Date {
  func isWithinPast(minutes: Int) -> Bool {
    let now = Date.now
    let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
    let range = timeAgo...now
    return range.contains(self)
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

