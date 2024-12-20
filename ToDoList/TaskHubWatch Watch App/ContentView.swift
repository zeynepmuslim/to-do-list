//
//  ContentView.swift
//  TaskHubWatch Watch App
//
//  Created by Zeynep Müslim on 20.12.2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var sessionManager = WatchSessionManagerW.shared
    
    var body: some View {
        if sessionManager.tasks.isEmpty {
        Text("No tasks found")
        }
        List(sessionManager.tasks) { task in
                    HStack {
                        Text(task.title)
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                }
                .onAppear {
                    print("Tasks received: \(sessionManager.tasks)")
                }
    }
}

#Preview {
    ContentView()
}
