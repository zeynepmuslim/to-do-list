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
    
    func getDueDateStatus(from dueDate: TimeInterval) -> (text: String, color: Color)? {
            let now = Date()
            let dueDate = Date(timeIntervalSince1970: dueDate)
            let calendar = Calendar.current

            if dueDate < now, !calendar.isDateInToday(dueDate) {
                return ("Overdue", .red)
            } else if calendar.isDateInToday(dueDate) {
                return ("Today", .blue)
            } else if calendar.isDateInTomorrow(dueDate) {
                return ("Tomorrow", .yellow)
            } else {
                return nil
            }
        }
    // "dd MMM" (e.g., "13 Dec")
    func formattedDate(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    //"dd MMM" (e.g., "13 Dec 2023")
    func formattedDateLong(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
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
