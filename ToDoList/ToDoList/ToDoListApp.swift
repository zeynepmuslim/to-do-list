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
    
    @StateObject var mainViewModel: MainViewModel = MainViewModel()
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = UITraitCollection.current.userInterfaceStyle == .dark
    var body: some Scene {
        WindowGroup {
            Group{
                if mainViewModel.isSignedIn, !mainViewModel.currentUserId.isEmpty {
                    TabView {
                        NavigationView {
                            ListView(userId: mainViewModel.currentUserId)
                        }
                        .tabItem {
                            Label("Tasks", systemImage: "checklist")
                        }
                        .navigationViewStyle(.stack)
//                        .toolbar(.hidden)
                        
                        // Settings Tab
                        NavigationView {
                            SettingsView()
                        }
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .navigationViewStyle(.stack)
//                        .toolbar(.hidden)
                    }
                    .accentColor(Color("AccentColor"))
//                    .transition(.scale)
                } else {
                    
                    Group{
                        NavigationView {
                            LoginView()
                        }
                        .navigationViewStyle(.stack)
                        .task {
                            await authController.startListeningToAuthState()
                        }
                    }
                    
                }
            }.environmentObject(authController)
                .preferredColorScheme(isDarkMode ? .dark : .light)
//

            }
        }
    
}
