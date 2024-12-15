//
//  LoginView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI
import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth


struct LoginView: View {
    
    @EnvironmentObject var authController: AuthController
    @StateObject var loginViewModel = LoginViewModel()
    
    
//    @Environment(AuthenticationState.self) private var authController
//    @State var email: String = ""
//    @State var password: String = ""
    
    var body: some View {
        VStack{
           // Header
            HeaderView()
            
            // Login Form
            VStack(spacing: 10) {
//                TextFieldCustom(placeholderr: "Email", textFieldContent: email)
               
                CustomTextField(placeholder: "Email", text: $loginViewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                CustomTextField(placeholder: "Password", text: $loginViewModel.password, isSecure: true)
                CustomButton(title: "Login") {
                    loginViewModel.login()
                    print(loginViewModel.email)
                    print(loginViewModel.password)
                }
            }
            .padding(.horizontal, 40)
            
            //gggogle
            VStack {
                GoogleSignInButton {
                    signIn()
                }
            }
            
            VStack{
                if !loginViewModel.errorMessage.isEmpty {
                    Text(loginViewModel.errorMessage)
                        .frame(height: 80)
                        .foregroundColor(.red)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .frame(height: 80)
            
                
            //Register
            VStack {
                Text("Don't have an account?")
                NavigationLink {
                    RegisterView()
                        .transition(AnyTransition.opacity.combined(with: .slide).animation(.easeInOut))
                } label: {
                    Text("Create An Account 👀")
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor"))
                }
                .disabled(false)
            }
            VStack {
                Text("forget Password")
                NavigationLink {
                    PasswordResetView()
                        .transition(AnyTransition.opacity.combined(with: .slide).animation(.easeInOut))
                } label: {
                    Text("forget Password 👀")
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor"))
                }
                .disabled(false)
            }
            
            Spacer()
        }
    }
    
    @MainActor
    func signIn() {
        Task {
            do {
                try await authController.signIn()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

#Preview {
    LoginView()
}
