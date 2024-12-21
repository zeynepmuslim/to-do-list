//
//  SettingsViewModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
    
}
