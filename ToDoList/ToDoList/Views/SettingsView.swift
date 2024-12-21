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
    
    @State private var animateTransition: Bool = false
    private var animationDuration: Double = 0.6
    // State to trigger animation
    
    var user: UserModel {
        settingsViewModel.user ?? UserModel(id: "", name: "", email: "", joined: 0)
    }
    
    var body: some View {
        ZStack{
            
            Color(isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: animationDuration), value: isDarkMode)
            //                .ignoresSafeArea(),
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
                    Text("Profile 🔎")
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
                            Text("Dark Mode")
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
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    isDarkMode.toggle()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("darkerSecond"))
                            //                                .animation(.easeInOut(duration: animationDuration), value: isDarkMode)
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        
                        List {
                            Section(header: Text("Settings")
                                .fontWeight(.semibold)
                                .padding(.top, 10)
                            ) {
                                Picker("Select Language", selection: $settingsViewModel.selectedLanguage) {
                                    ForEach(settingsViewModel.languageOptions, id: \.self) { language in
                                        Text(language)
                                    }
                                }
                                NavigationLink(destination: PasswordResetView(isFromSettings: true)) {
                                    Text("Change Password")
                                }
                                Button(action: {
                                    showAlert = true
                                }) {
                                    Text("Delete Account")
                                        .foregroundColor(.red)
                                }
                                .alert("Confirm Delete", isPresented: $showAlert, actions: {
                                    SecureField("Enter your password", text: $password)
                                    
                                    Button("Delete", role: .destructive) {
                                        Task {
                                            do {
                                                try await settingsViewModel.deleteCurrentUser(password: password)
                                                DispatchQueue.main.async {
                                                    navigateToLogin = true // LoginView'e geçiş
                                                }
                                            } catch {
                                                errorMessage = error.localizedDescription
                                                print("Error deleting user: \(error.localizedDescription)")
                                            }
                                        }
                                    }

                                    Button("Cancel", role: .cancel) {
                                        password = "" // Şifreyi temizle
                                    }
                                }, message: {
                                    if !errorMessage.isEmpty {
                                        Text(errorMessage) // Hata mesajını göster
                                    } else {
                                        Text("Please enter your password to confirm.")
                                    }
                                })
                                Button(action: {
                                    settingsViewModel.logOut()
                                }) {
                                    Text("Log out")
                                        .foregroundColor(.red)
                                }
                            }
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
                
                //                Spacer()
                //                Spacer()
            }
                           // LoginView'e geçiş
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
        
        
    }
    
    
    
}

#Preview {
    NavigationView {
        SettingsView()
    }
    .navigationViewStyle(.stack)
}
