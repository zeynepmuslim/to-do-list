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
import AuthenticationServices

struct SignInWithAppleButtonViewRepressentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

struct LoginView: View {
    
    @EnvironmentObject var authController: AuthController
    @StateObject var loginViewModel = LoginViewModel()
    @State private var showErrorMessage = false
    
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
                        
                        CustomTextField(placeholder: "Password", text: $loginViewModel.password, isSecure: false)
                            .textContentType(.password)
                            .focused($fieldFocus, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                validateFields()
                                loginViewModel.login()
                            }
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: isPasswordVisible)
                    } else {
                        
                        CustomTextField(placeholder: "Password", text: $loginViewModel.password, isSecure: true)
                            .textContentType(.password)
                            .focused($fieldFocus, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                validateFields()
                                loginViewModel.login()
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
                    NavigationLink(destination: PasswordResetView(isFromSettings: false)) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .padding(.trailing, 10)
                
                
                
                CustomButton(title: "Login") {
                    //                    hideKeyboard()
                    validateFields()
                    loginViewModel.login()
                    print(loginViewModel.email)
                    print(loginViewModel.password)
                }
            }
            .padding(.horizontal, 40)
            
            //gggogle
            HStack {
                //                Spacer()
                GoogleSignInButton(scheme: .light, style: .standard, state: .normal, action: {
                    signInWithGoogle()
                })
                .frame(height: 40)
                .cornerRadius(10)
                .shadow(color: .secondary.opacity(0.4), radius: 7, x: 0, y: 10)
                Spacer()
                Button {
                    signInWithApple()
                } label: {
                    SignInWithAppleButtonViewRepressentable(type: .signIn, style: .white)
                        .allowsHitTesting(false)
                        .frame(height: 40)
                        .cornerRadius(10)
                        .shadow(color: .secondary.opacity(0.4), radius: 7, x: 0, y: 10)
                    
                }
            }
            .padding(.horizontal, 40)
            
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
                Spacer()
                Button("Close") {
                    hideKeyboard()
                }
                .foregroundColor(Color("AccentColor"))
            }
        }
    }
    
    func hideKeyboard() {
        fieldFocus = nil
    }
    
    func triggerHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func validateFields() {
        if loginViewModel.email.isEmpty {
            fieldFocus = .email
        } else if loginViewModel.password.isEmpty {
            fieldFocus = .password
        } else {
            fieldFocus = nil
        }
    }
    
    @MainActor
    func signInWithGoogle() {
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
    LoginView()
}
