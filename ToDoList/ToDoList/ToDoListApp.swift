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
    
    @StateObject var listViewModel: ListViewModel = ListViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
              //  ListView()
            }
            .navigationViewStyle(.stack)
            .environmentObject(listViewModel)
        }
    }
}
