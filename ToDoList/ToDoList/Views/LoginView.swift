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
    @State private var showErrorMessage = false
    
    //    @Environment(AuthenticationState.self) private var authController
    //    @State var email: String = ""
    //    @State var password: String = ""
    @FocusState private var fieldFocus: OnboardingFields?
    
    enum OnboardingFields: Hashable {
        case email
        case password
    }
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack{
            HeaderView()
            
            VStack(spacing: 10) {
                
                CustomTextField(placeholder: "Email", text: $loginViewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .focused($fieldFocus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        fieldFocus = .password
                    }
                
                ZStack(alignment: .trailing) {
                    if isPasswordVisible {
                        // Şifre görünür durumda
                        CustomTextField(placeholder: "Password", text: $loginViewModel.password, isSecure: false)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Close") {
                                        hideKeyboard()
                                    }
                                }
                            }
                            .textContentType(.password)
                            .focused($fieldFocus, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                hideKeyboard()
                                validateFields()
                                loginViewModel.login()
                            }
                            .transition(.opacity) // Opacity geçişi ekliyoruz
                            .animation(.easeInOut(duration: 0.3), value: isPasswordVisible)
                    } else {
                        // Şifre gizli durumda
                        CustomTextField(placeholder: "Password", text: $loginViewModel.password, isSecure: true)
                            .textContentType(.password)
                            .focused($fieldFocus, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                hideKeyboard()
                                validateFields()
                                loginViewModel.login()
                            }
                            .transition(.opacity) // Opacity geçişi ekliyoruz
                            .animation(.easeInOut(duration: 0.3), value: isPasswordVisible)
                    }
                    
                    Button(action: {
                        withAnimation {
                            isPasswordVisible.toggle()
                        }
                    }) {
                        Image(systemName: !isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(), value: isPasswordVisible)
                    }
                }
                HStack(alignment: .center) {
                    if !loginViewModel.errorMessage.isEmpty {
                                       Text(loginViewModel.errorMessage)
                                           .foregroundColor(.red)
                                           .italic()
                                           .padding(10)
                                           .background(Color.red.opacity(0.1))
                                           .cornerRadius(8)
                                           .frame(maxWidth: .infinity, alignment: .leading)
                                           .transition(.opacity)
                                           .animation(.easeInOut, value: showErrorMessage)
                                   }
                    Spacer()
                    NavigationLink(destination: PasswordResetView()) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .padding(.trailing, 10)
                
                
                
                CustomButton(title: "Login") {
                    hideKeyboard()
                    validateFields()
                    loginViewModel.login()
                    print(loginViewModel.email)
                    print(loginViewModel.password)
                }
            }
            .padding(.horizontal, 40)
            
            //gggogle
            VStack {
                
                GoogleSignInButton(scheme: .light, style: .icon, state: .normal, action: {
                    signIn()
                })
                .cornerRadius(10)
                .shadow(color: .secondary.opacity(0.4), radius: 7, x: 0, y: 10)
            }
            
            Spacer()
            
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
            
            Spacer()
        }
        
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                
                Button("Close") {
                    hideKeyboard()
                }
                Spacer()
                Button("Login") {
                    hideKeyboard()
                    validateFields()
                    loginViewModel.login()
                }
            }
        }
    }
    
    func hideKeyboard() {
        fieldFocus = nil // Focus'u kaldır ve klavyeyi kapat
    }
    
    func validateFields() {
        if loginViewModel.email.isEmpty {
            fieldFocus = .email // Email alanına odaklan
        } else if loginViewModel.password.isEmpty {
            fieldFocus = .password // Password alanına odaklan
        } else {
            fieldFocus = nil // Her iki alan da dolu
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
