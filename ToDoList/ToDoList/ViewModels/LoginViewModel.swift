//
//  LoginViewModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//
import FirebaseAuth
import Foundation
class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    
    
    init() {
        
    }
    
    func login() {
        guard validate() else {
            print("Validation failed")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error as NSError? {
                        // Firebase Hatalarını Özelleştir
                        strongSelf.handleAuthError(error)
                        return
            }
            
            print("Login successful")
        }
        
    }
    func validate() -> Bool {
        errorMessage = ""
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Please fill in all fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email."
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }
        return true
    }
    
    func handleAuthError(_ error: NSError) {
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .wrongPassword:
                errorMessage = "The password is incorrect. Please try again."
            case .invalidEmail:
                errorMessage = "The email address is not valid. Please check again."
            case .userNotFound:
                errorMessage = "No account found with this email. Please sign up."
            case .networkError:
                errorMessage = "Network error. Please check your connection."
            case .invalidCredential:
                errorMessage = "Your authentication credential is malformed or expired."
                
            default:
                errorMessage = "Error: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "An unknown error occurred. Please try again."
        }
        print(errorMessage)
    }
    
    
}



