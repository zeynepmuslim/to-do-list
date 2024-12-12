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
    
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var mainViewModel: MainViewModel = MainViewModel()
    @StateObject var listViewModel: ListViewModel = ListViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                
                if mainViewModel.isSignedIn, !mainViewModel.currentUserId.isEmpty {
                    ListView()
                } else {
                    LoginView()
                }
              //  ListView()
            }
            .navigationViewStyle(.stack)
            .environmentObject(listViewModel)
        }
    }
}
