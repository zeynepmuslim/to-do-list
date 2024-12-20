//
//  PasswordResetView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 15.12.2024.
//


import FirebaseAuth
import SwiftUI

import FirebaseAuth
import SwiftUI

struct PasswordResetView: View {
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var showAlert: Bool = false
    let theWidth = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var isFromSettings: Bool = false // Ayarlar sekmesinden mi geldiği kontrol edilir
    @Environment(\.presentationMode) var presentationMode // Geri dönüş için
    @State private var navigateToLogin = false // LoginView'e yönlendirme kontrolü

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                Text(isFromSettings ? "Update Password" : "Reset Password")
                    .font(.largeTitle)
                    .bold()

                if !isFromSettings {
                    TextField("Enter your email address", text: $email)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                } else {
                    Text("Reset password link will be sent to your registered email. You will be logged out of your account after this process.")
                        .foregroundColor(.gray)
                }

                CustomButton(title: isFromSettings ? "Send Password Update Link" : "Send Reset Link") {
                    resetPassword()
                }
                .disabled(!isFromSettings && email.isEmpty)
                .opacity(!isFromSettings && email.isEmpty ? 0.5 : 1.0)// Email boşken butonu devre dışı bırak

                Text(message)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            .padding()
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
            if message.contains("Error") {
                return Alert(
                    title: Text("Error"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            } else {
                return Alert(
                    title: Text("Success"),
                    message: Text(message),
                    dismissButton: .default(Text("OK")) {
                        if isFromSettings {
                            logOutAfterPasswordChange() // Şifre güncellendikten sonra logout
                        } else {
                            navigateToLogin = true // Login'e yönlendir
                        }
                    }
                )
            }
        }
        .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left.2")
                                }
                            }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
        .background(
            NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                EmptyView()
            }
        )
    }

    func resetPassword() {
        guard let targetEmail = getTargetEmail() else {
            message = "Could not retrieve your email. Please try logging in again."
            showAlert = true
            return
        }

        Auth.auth().sendPasswordReset(withEmail: targetEmail) { error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "A password reset link has been sent to your email address."
            }
            showAlert = true
        }
    }

    func logOutAfterPasswordChange() {
        do {
            try Auth.auth().signOut() // Firebase'den çıkış yap
            navigateToLogin = true // Kullanıcıyı LoginView'e yönlendir
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            message = "An error occurred while logging out. Please try again."
            showAlert = true
        }
    }
    private func getTargetEmail() -> String? {
         if isFromSettings {
             return Auth.auth().currentUser?.email
         } else {
             return email.isEmpty ? nil : email
         }
     }
}
#Preview {
    PasswordResetView(isFromSettings: true)
}
