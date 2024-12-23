//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import FirebaseCore
import SwiftUI

/*
 
 MVVM Architecture
 Model - Data
 View - UI
 ViewModel - Business Logic
 
 */

@main
struct ToDoListApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var authController = AuthController()
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject var mainViewModel: MainViewModel = MainViewModel()
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = UITraitCollection.current.userInterfaceStyle == .dark
    @AppStorage("AppLanguage") private var selectedLanguage: String = "en"
    
    var body: some Scene {
        WindowGroup {
            Group{
                if mainViewModel.isSignedIn, !mainViewModel.currentUserId.isEmpty {
                    TabView {
                        NavigationView {
                            ListView(userId: mainViewModel.currentUserId)
                        }
                        .tabItem {
                            Label("tasks".localized(), systemImage: "checklist")
                        }
                        .navigationViewStyle(.stack)
                        NavigationView {
                            SettingsView()
                        }
                        .tabItem {
                            Label("profile".localized(), systemImage: "person.fill")
                        }
                        .navigationViewStyle(.stack)
                    }
                    .accentColor(Color("AccentColor"))
                } else {
                    
                    Group{
                        NavigationView {
                            LoginView()
                        }
                        .tint(Color("AccentColor"))
                        .navigationViewStyle(.stack)
                        .task {
                            await authController.startListeningToAuthState()
                        }
                    }
                    
                }
            }
            .environmentObject(authController)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environmentObject(settingsViewModel)
                .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                    settingsViewModel.objectWillChange.send()
                }
        }
    }
    
}
