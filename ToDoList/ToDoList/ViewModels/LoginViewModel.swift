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
            
            guard error == nil else {
                strongSelf.errorMessage = error!.localizedDescription
                print("Login failed: \(error!.localizedDescription)")
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
}
