//
//  PasswordResetView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 15.12.2024.
//


import FirebaseAuth
import SwiftUI

struct PasswordResetView: View {
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Şifre Yenile")
                .font(.largeTitle)
                .bold()
            
            TextField("E-posta adresinizi girin", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: resetPassword) {
                Text("Şifre Sıfırlama Bağlantısı Gönder")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text(message)
                .foregroundColor(.red)
                .font(.footnote)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(message), dismissButton: .default(Text("Tamam")))
        }
    }
    
    func resetPassword() {
        guard !email.isEmpty else {
            message = "E-posta adresini girin."
            showAlert = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "Hata: \(error.localizedDescription)"
            } else {
                message = "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."
            }
            showAlert = true
        }
    }
    
    
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

#Preview {
    PasswordResetView()
}
