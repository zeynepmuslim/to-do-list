//
//  PriorityView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 24.12.2024.
//


import SwiftUI

struct PriorityView: View {
    @Binding var selectedPriority: String
    let priorities: [(key: String, localizedKey: String, iconCount: Int, color: Color, emoji: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("priority".localized())
                    .font(.headline)
                Spacer()
                
                if let selected = priorities.first(where: { $0.key == selectedPriority }) {
                    Group {
                        ForEach(0..<selected.iconCount, id: \.self) { _ in
                            Image(systemName: "star.fill")
                        }
                    }
                    .foregroundColor(selected.color)
                    .transition(.scale)
                    
                    Text(selected.emoji)
                        .transition(.opacity)
                }
            }
            .padding(.top, 10)
            .animation(.easeInOut, value: selectedPriority)
            
            Picker("priority".localized(), selection: $selectedPriority) {
                ForEach(priorities, id: \.key) { priority in
                    Text(priority.localizedKey.localized())
                        .tag(priority.key)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}
