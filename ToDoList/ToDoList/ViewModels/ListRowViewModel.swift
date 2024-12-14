//
//  ListRowViewModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 13.12.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUICore

class ListRowViewModel: ObservableObject {
    init() {
    }
    
    func toggleIsDone(item: TaskModel) {
        var itemCopy = item
        itemCopy.isCompleted.toggle()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("tasks")
            .document(item.id)
            .setData(itemCopy.asDictionary())
        
    }
    
    // Helper to format the date into "dd MMM" (e.g., "13 Dec")
    func formattedDate(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    func formattedDateLong(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy" // Format for "10 July 2010"
        return formatter.string(from: date)
    }
    
    // Helper functions for category and priority symbols/colors
    func categorySymbol(for category: String) -> String {
        switch category {
        case "other": return "diamond.fill"
        case "home": return "house.fill"
        case "school": return "book.fill"
        case "job": return "briefcase.fill"
        default: return "tag"
        }
    }
    
    func categoryColor(for category: String) -> Color {
        switch category {
        case "other": return .red
        case "home": return .orange
        case "school": return .green
        case "job": return .blue
        default: return .red
        }
    }
    
    func prioritySymbol(for priority: String) -> String {
        switch priority {
        case "High": return "star.fill"
        case "Medium": return "star.lefthalf.fill"
        case "Low": return "star"
        default: return "circle"
        }
    }
    
    func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .yellow
        case "Low": return .gray
        default: return .gray
        }
    }
}
