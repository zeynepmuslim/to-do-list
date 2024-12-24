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
    var isFromSettings: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToLogin = false
    
    var body: some View {
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 20) {
                    Text(isFromSettings ? "update_password".localized() : "reset_password".localized())
                        .font(.largeTitle)
                        .bold()
                    
                    if !isFromSettings {
                        TextField("enter_your_email_address".localized(), text: $email)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    } else {
                        Text("reset_password_instructions".localized())
                            .foregroundColor(.gray)
                    }
                    
                    CustomButton(title: isFromSettings ? "send_password_update_link".localized() : "send_reset_link".localized()) {
                        resetPassword()
                    }
                    .disabled(!isFromSettings && email.isEmpty)
                    .opacity(!isFromSettings && email.isEmpty ? 0.5 : 1.0)
                    
                    Text(message)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                .padding()
                Spacer()
                if navigateToLogin {
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
            }
            .onDisappear {
                presentationMode.wrappedValue.dismiss()
            }
            .customNavigation()
            .alert(isPresented: $showAlert) {
                if message.contains("error".localized()) {
                    return Alert(
                        title: Text("error".localized()),
                        message: Text(message),
                        dismissButton: .default(Text("ok".localized()))
                    )
                } else {
                    return Alert(
                        title: Text("success".localized()),
                        message: Text(message),
                        dismissButton: .default(Text("ok".localized())) {
                            if isFromSettings {
                                logOutAfterPasswordChange()
                            } else {
                                navigateToLogin = true
                            }
                        }
                    )
                }
            }
            .background(
                NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                    EmptyView()
                }
            )
        
    }
    
    func resetPassword() {
        guard let targetEmail = getTargetEmail() else {
            message = "could_not_retrieve_email".localized()
            showAlert = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: targetEmail) { error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "password_reset_link_sent".localized()
            }
            showAlert = true
        }
    }
    
    func logOutAfterPasswordChange() {
        do {
            try Auth.auth().signOut()
            navigateToLogin = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            message = "logout_error".localized()
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
