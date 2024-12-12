//
//  SettingsView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
            Text("Settings View")
        }
        .navigationTitle("Settings ⚙️")
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
