//
//  ListRowView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI

struct ListRowView: View {
    
    let item: ItemModel
    
    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle" : "circle")
                .foregroundColor(item.isCompleted ? .green : .red)
            Text(item.title)
            Spacer()
        }
        .listRowBackground(Color(UIColor.secondarySystemBackground))
        .font(.title2)
        .padding(.vertical, 8)
    }
}


#Preview {
    Group {
        
        ListRowView(item: ItemModel(title: "Second Task!", isCompleted: true))
    }
}
