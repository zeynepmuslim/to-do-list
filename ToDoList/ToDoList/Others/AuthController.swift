//
//  AuthController.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 16.12.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import CryptoKit
import AuthenticationServices

class AuthController: NSObject, ObservableObject {
    @Published var authState: AuthState = .undefined
    //    @Published var didSignInWithApple = false
    fileprivate var currentNonce: String?
    
    func startListeningToAuthState() async {
        Auth.auth().addStateDidChangeListener { _, user in
            self.authState = user != nil ? .authenticated : .unauthenticated
        }
    }
    
    @MainActor
    func signInsignInWithGoogle() async throws {
            guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController else {
                    throw NSError(domain: "Google Sign-In Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])
                }

            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(domain: "Google Sign-In Error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase client ID."])
            }

            let configuration = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = configuration

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "Google Sign-In Error", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch Google ID token."])
            }
            let accessToken = result.user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let authResult = try await Auth.auth().signIn(with: credential)

            try await createUserDocumentIfNeeded(authResult.user)
    }
    
    private func createUserDocumentIfNeeded(_ user: User) async throws {
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)

        let documentSnapshot = try await userDocRef.getDocument()
        if !documentSnapshot.exists {
            let userData: [String: Any] = [
                "id": user.uid,
                "name": user.displayName ?? "Unknown Name",
                "email": user.email ?? "No Email",
                "joined": Date().timeIntervalSince1970
            ]
            try await userDocRef.setData(userData)
            print("User document created for: \(user.email ?? "No Email")")
        } else {
            print("User document already exists.")
        }
    }
    
    @MainActor
    func signInsignInWithApple() async throws {
        startSignInWithAppleFlow()
    }
    
    @MainActor
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @MainActor
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @MainActor
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func saveUserToFirestore(uid: String, email: String?, name: String?) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "id": uid,
                    "email": email ?? "No Email",
            "name": name ?? "No Name",
                    "joined": Date().timeIntervalSince1970
        ]) { error in
            if let error = error {
                print("Error saving user to Firestore: \(error.localizedDescription)")
            } else {
                print("User saved to Firestore successfully.")
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

extension AuthController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}
extension AuthController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let AppleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: AppleIDToken, encoding: .utf8),
            let nonce = currentNonce else {
            print("Unable to fetch nonce for Apple Sign-In")
            return
        }
        
        Task {
            do {
                try await signInApple(idTokenString: idTokenString, rawNonce: nonce)
                print("Apple Sign-In successful")
                
                if let user = Auth.auth().currentUser {
                    if let givenName = appleIDCredential.fullName?.givenName,
                           let familyName = appleIDCredential.fullName?.familyName {
                            let fullName = "\(givenName) \(familyName)"
                            let email = appleIDCredential.email ?? user.email
                            saveUserToFirestore(uid: user.uid, email: email, name: fullName)
                        } else {
                            print("Full name not available for this login session. Skipping name update.")
                        }
                            }
            } catch {
                print("Apple Sign-In failed: \(error)")
            }
        }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            
        }
    }
    
    @MainActor
    func signInApple(idTokenString: String, rawNonce: String) async throws {
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: rawNonce
        )
        
        do {
            let result = try await Auth.auth().signIn(with: credential)
            print("User signed in: \(result.user.uid)")
        } catch {
            print("Error during Apple Sign-In: \(error.localizedDescription)")
            throw error
        }
    }
   
}
func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("Sign in with Apple errored: \(error)")
}


