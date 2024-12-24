//
//  SettingsView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var showAlert = false
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var navigateToLogin = false
    @StateObject var settingsViewModel = SettingsViewModel()
    let theWidth = UIScreen.main.bounds.width
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = UITraitCollection.current.userInterfaceStyle == .dark
    
    @State private var reloadView = false
    @State private var animateTransition: Bool = false
    @State private var showAccountDeletionAlert = false
    private var animationDuration: Double = 0.6
    
    var user: UserModel {
        settingsViewModel.user ?? UserModel(id: "", name: "", email: "", joined: 0)
    }
    
    var body: some View {
        ZStack{
            Color(isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: animationDuration), value: isDarkMode)
            HStack{
                Spacer()
                VStack{
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
                        .frame(width: theWidth / 2.5, height: theWidth / 2.5 )
                        .offset(y: -40)
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("profile".localized() + " 🔎")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Spacer()
                }
                .padding(.horizontal,20)
                .padding(.top, 15)
                
                if let user = settingsViewModel.user {
                    
                    VStack {
                        Image(systemName: "person.fill")
                            .frame(width: 100, height: 100)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color("AccentColor")))
                            .shadow(
                                color: Color("AccentColor").opacity(0.5),
                                radius: 20,
                                x: 0,
                                y: 10)
                        VStack {
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.bold)
                            Text(user.email)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .padding(.horizontal,30)
                        }
                        .multilineTextAlignment(TextAlignment.center)
                        .padding(20)
                        
                        
                        HStack {
                            Text("dark_mode".localized())
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(isDarkMode ? Color.black : Color.yellow.opacity(0.7))
                                    .frame(width: 50, height: 50)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isDarkMode)
                                
                                Text(isDarkMode ? "🌙" : "☀️")
                                    .font(.system(size: 30))
                                    .rotationEffect(.degrees(animateTransition ? 180 : -10))
                                    .animation(.easeInOut(duration: 0.5), value: animateTransition)
                            }
                            .onTapGesture {
                                withAnimation {
                                    animateTransition.toggle()
                                    isDarkMode.toggle()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("darkerSecond"))
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        List {
                            Section(header: Text("settings".localized())
                                .fontWeight(.semibold)
                                .padding(.top, 10)
                            ) {
                                Picker("selected_language".localized(), selection: $settingsViewModel.selectedLanguage) {
                                    ForEach(settingsViewModel.languageOptions, id: \.self) { language in
                                        Text(language.localized())
                                    }
                                }
                                NavigationLink(destination: PasswordResetView(isFromSettings: true)) {
                                    Text("change_password".localized())
                                }
                                Button(action: {
                                    settingsViewModel.logOut()
                                }) {
                                    Text("log_out".localized())
                                        .foregroundColor(.red)
                                }
                                Button{
                                    showAccountDeletionAlert.toggle()
                                } label: {
                                    Text("delete_account".localized())
                                        .foregroundColor(.red)
                                }
                                .alert("we're_sorry_to_see_you_go".localized(), isPresented: $showAccountDeletionAlert, actions: {
                                    Button("yes_delete_my_account".localized(), role: .destructive) {
                                        showAccountDeletionAlert = false
                                        Task {
                                            let success = await settingsViewModel.deleteAccount()
                                            if success {
                                                print("Account deleted successfully!")
                                            } else {
                                                print("Failed to delete account.")
                                            }
                                        }
                                    }
                                    Button("no_keep_my_account".localized(), role: .cancel) {
                                        showAccountDeletionAlert = false
                                    }
                                }, message: {
                                    Text("we're_sad_to_see_you_go".localized())
                                })
                            }
                            .alert("enter_your_password".localized(), isPresented: $settingsViewModel.showPasswordAlert, actions: {
                                SecureField("please_confirm_your_password".localized(), text: $settingsViewModel.passwordInput)
                                Button("confirm_deletion".localized()) {
                                    settingsViewModel.passwordContinuation?.resume(returning: settingsViewModel.passwordInput)
                                    settingsViewModel.passwordContinuation = nil
                                    settingsViewModel.passwordInput = ""
                                }
                                Button("cancel".localized(), role: .cancel) {
                                    settingsViewModel.passwordContinuation?.resume(returning: "")
                                    settingsViewModel.passwordContinuation = nil
                                    settingsViewModel.passwordInput = ""
                                }
                            })
                            .listRowBackground(Color("darkerSecond"))
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(InsetGroupedListStyle())
                    }
                    .padding(.top, 50)
                    
                } else {
                    Spacer()
                    VStack {
                        ProgressView()
                            .scaleEffect(2)
                            .padding()
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            NavigationLink(
                destination: LoginView(),
                isActive: $navigateToLogin
            ) {
                EmptyView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear{
            settingsViewModel.fetchUser()
        }
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            reloadView.toggle()
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
    .navigationViewStyle(.stack)
}
