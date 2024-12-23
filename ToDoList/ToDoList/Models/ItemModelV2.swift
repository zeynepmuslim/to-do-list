//
//  ItemModelV2.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//
import FirebaseFirestore
import FirebaseAuth
import Foundation

class ItemModelV2: ObservableObject {
    @Published var id: String = UUID().uuidString
    @Published var title: String = ""
    @Published var priority: String = "Low"
    @Published var category: String = "other"
    @Published var dueDate: Date? = nil
    @Published var thereIsDate: Bool = false
    @Published var createdAt: TimeInterval = Date().timeIntervalSince1970
    @Published var isCompleted: Bool = false
    
    init() {}
    
    func save() {
        print("Saved")
        
        guard let uId = FirebaseAuth.Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        
        let task = TaskModel(
            id: id,
            title: title,
            priority: priority,
            category: category,
            dueDate: dueDate?.timeIntervalSince1970,
            thereIsDate: dueDate != nil,
            createdAt: createdAt,
            isCompleted: isCompleted
        )
        
        do {
            try db.collection("users")
                .document(uId)
                .collection("tasks")
                .document(id)
                .setData(from: task)
        } catch {
            print("Error saving task: \(error)")
        }
    }
}
