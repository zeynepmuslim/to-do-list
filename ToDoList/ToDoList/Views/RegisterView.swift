//
//  RegisterView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var authController: AuthController
    @StateObject var registerViewModel = RegisterViewModel()
    
    @FocusState private var fieldFocus: OnboardingFields?
    @State private var showErrorMessage = false
    
    enum OnboardingFields: Hashable {
        case name
        case email
        case password
    }
    
    @State private var isPasswordVisible = false
    
    let theWidth = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(Color("AccentColor"))
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: theWidth,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 0
                            )
                        )
                        .ignoresSafeArea()
                        .frame(width: theWidth / 2, height: theWidth / 2 )
                        .offset(y: -40)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Create our hub of tasks now! 🚀")
                    .font(.title)
                    .bold()
                CustomTextField(placeholder: "Full Name", text: $registerViewModel.name)
                    .focused($fieldFocus, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        fieldFocus = .email
                    }
                
                CustomTextField(placeholder: "Email", text: $registerViewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .focused($fieldFocus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        fieldFocus = .password
                    }
                ZStack(alignment: .trailing) {
                    if isPasswordVisible {
                        CustomTextField(placeholder: "Password", text: $registerViewModel.password, isSecure: false)
                            .textContentType(.password)
                            .focused($fieldFocus, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {                                validateFields()
                                registerViewModel.register()
                            }
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: isPasswordVisible)
                    } else {
                        CustomTextField(placeholder: "Password", text: $registerViewModel.password, isSecure: true)
                            .textContentType(.password)
                            .focused($fieldFocus, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                validateFields()
                                registerViewModel.register()
                            }
                            .transition(.opacity)
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
                            .transition(.opacity)
                            .animation(.spring(), value: isPasswordVisible)
                    }
                }
                
                if !registerViewModel.errorMessage.isEmpty {
                                   Text(registerViewModel.errorMessage)
                                       .foregroundColor(.red)
                                       .italic()
                                       .padding(10)
                                       .background(Color.red.opacity(0.1))
                                       .cornerRadius(8)
                                       .frame(maxWidth: .infinity, alignment: .leading)
                                       .transition(.opacity)
                                       .animation(.easeInOut, value: showErrorMessage)
                               }
                
                CustomButton(title: "Register") {
                    validateFields()
                    registerViewModel.register()
                    print(registerViewModel.name)
                    print(registerViewModel.email)
                    print(registerViewModel.password)
                }
                
                HStack {
                    GoogleSignInButton(scheme: .light, style: .standard, state: .normal, action: {
                        signIn()
                    })
                    .cornerRadius(10)
                    .shadow(color: .secondary.opacity(0.4), radius: 7, x: 0, y: 10)
                    
                    Button {
                        signInWithApple()
                    } label: {
                        
                        SignInWithAppleButtonViewRepressentable(type: .signUp, style: .white)
                            .allowsHitTesting(false)
                            .frame(height: 40)
                            .cornerRadius(10)
                            .shadow(color: .secondary.opacity(0.4), radius: 7, x: 0, y: 10)
                    }

                }
                
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
            Spacer()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    hideKeyboard()
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
    }
    
    func hideKeyboard() {
        fieldFocus = nil
    }
    
    func validateFields() {
        if registerViewModel.email.isEmpty {
            fieldFocus = .email
        } else if registerViewModel.password.isEmpty {
            fieldFocus = .password
        } else {
            fieldFocus = nil
        }
    }
    
    @MainActor
    func signIn() {
        Task {
            do {
                try await authController.signInsignInWithGoogle()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func signInWithApple() {
        Task {
            do {
                try await authController.signInsignInWithApple()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    RegisterView()
}
