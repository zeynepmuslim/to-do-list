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
    
    
    
    var user: UserModel {
        settingsViewModel.user ?? UserModel(id: "", name: "", email: "", joined: 0)
    }
    
    var body: some View {
        ZStack{
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
                Spacer()
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
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Advanced Settings")
                                .font(.headline)

                            Button(action: {
                                // Şifre değiştirme işlemi
                            }) {
                                Text("Change Password")
                                    .foregroundColor(.blue)
                            }

                            Button(action: {
                                // Hesap silme işlemi
                            }) {
                                Text("Delete Account")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Language")
                                .font(.headline)

                            Picker("Select Language", selection: $settingsViewModel.selectedLanguage) {
                                ForEach(settingsViewModel.languageOptions, id: \.self) { language in
                                    Text(language)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        List {
                            Picker("Select Language", selection: $settingsViewModel.selectedLanguage) {
                                ForEach(settingsViewModel.languageOptions, id: \.self) { language in
                                    Text(language)
                                }
                            }
                            Button(action: {
                                // Şifre değiştirme işlemi
                            }) {
                                Text("Change Password")
                                    .foregroundColor(.blue)
                            }
                            Button(action: {
                                // Hesap silme işlemi
                            }) {
                                Text("Delete Account")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        VStack{
                            Button{
                                
                            } label: {
                                CustomButton(title: "Log Out") {
                                    settingsViewModel.logOut()                                }
                            }
                        }
                        .padding(.horizontal,40)
                    }
                } else {
                    VStack {
                            ProgressView() // Yükleme animasyonu
                                .scaleEffect(2)
                                .padding()
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                }
                
                Spacer()
                Spacer()
            }
            
        }
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
