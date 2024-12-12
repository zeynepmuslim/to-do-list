//
//  LoginViewModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//
import Foundation
class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    
    init() {
        
    }
    
    func login() {
        errorMessage = ""
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email."
            return
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            return
        }
    }
    func validate() {
        
    }
}
