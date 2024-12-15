//
//  AuthController.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 16.12.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class AuthController: ObservableObject {
    @Published var authState: AuthState = .undefined
    
    func startListeningToAuthState() async {
        Auth.auth().addStateDidChangeListener { _, user in
            self.authState = user != nil ? .authenticated : .unauthenticated
        }
    }
    
    @MainActor
    func signIn() async throws {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {return}
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {return}
        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        try await Auth.auth().signIn(with: credential)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
