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
    
    let theWidth = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                Text("Reset Password")
                    .font(.largeTitle)
                    .bold()
                
                CustomTextField(placeholder: "Enter your email address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                CustomButton(title: "Send Password Reset Link") {
                    resetPassword()
                }
                
                Text(message)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            .padding()
            Spacer()
            Spacer()
            
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(Color("AccentColor"))
                    .clipShape(
                        .rect(
                            topLeadingRadius: theWidth,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                    )
                    .ignoresSafeArea()
                    .frame(width: theWidth / 2, height: theWidth / 2 )
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Information"), message: Text(message), dismissButton: .default(Text("Tamam")))
        }
    }
    
    func resetPassword() {
        guard !email.isEmpty else {
            message = "Please enter your email address."
            showAlert = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "A password reset link has been sent to your email address."
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
