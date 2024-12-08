//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI

/*
 
 MVVM Architecture
 Model - Data
 View - UI
 ViewModel - Business Logic
 
 */

@main
struct ToDoListApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListView()
            }
        }
    }
}
