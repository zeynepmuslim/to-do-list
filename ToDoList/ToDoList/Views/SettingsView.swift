//
//  SettingsView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI

struct SettingsView: View {
    
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
                        .padding(20)
                        
                        
                        HStack {
                            Text("Dark Mode")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            ZStack {
                                // Background for the emoji
                                Circle()
                                    .fill(isDarkMode ? Color.black : Color.yellow.opacity(0.7))
                                    .frame(width: 50, height: 50)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isDarkMode)
                                
                                // Sun and moon emojis with rotation
                                Text(isDarkMode ? "🌙" : "☀️")
                                    .font(.system(size: 30))
                                    .rotationEffect(.degrees(animateTransition ? 180 : -10))
                                    .animation(.easeInOut(duration: 0.5), value: animateTransition)
                            }
                            .onTapGesture {
                                // Animate the transition
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
                                .animation(.easeInOut(duration: animationDuration), value: isDarkMode)
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                    
                        
//                        HStack {
//                            Text("Dark Mode Switch")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                            Spacer()
//                            ZStack {
//                                Circle()
//                                    .fill(isDarkMode ? Color.black : Color.yellow)
//                                    .frame(width: 50, height: 50)
//                                    .animation(.spring(), value: isDarkMode)
//                                
//                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
//                                    .foregroundColor(isDarkMode ? .white : .orange)
//                                    .font(.system(size: 24))
//                                    .animation(.easeInOut, value: isDarkMode)
//                            }
//                            .onTapGesture {
//                                isDarkMode.toggle()
//                            }
//                        }
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color("darkerSecond"))
//                        )
//                        .padding(.horizontal)
                        // List with a Section for the title
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
                                NavigationLink(destination: PasswordResetView()) {
                                    Text("Change Password")
                                }
                                Button(action: {
                                    
                                }) {
                                    Text("Delete Account")
                                        .foregroundColor(.red)
                                }
                                Button(action: {
                                    settingsViewModel.logOut()
                                }) {
                                    Text("Log out")
                                        .foregroundColor(.red)
                                }
                            }
                            .listRowBackground(Color(isDarkMode ? Color.darkerSecond : Color.darkerSecond)
                                .edgesIgnoringSafeArea(.all)
                                .animation(.easeInOut(duration: animationDuration), value: isDarkMode))
                            
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(InsetGroupedListStyle())
                        
                    }
                    .padding(.top, 50)
                    
                } else {
                    VStack {
                        ProgressView()
                            .scaleEffect(2)
                            .padding()
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                //                Spacer()
                //                Spacer()
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
