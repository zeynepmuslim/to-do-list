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
    @Published var id: String = UUID().uuidString // Benzersiz kimlik
    @Published var title: String = "" // Görev başlığı
    @Published var priority: String = "Low" // Görev önceliği ("Low", "Medium", "High")
    @Published var category: String = "other" // Görev kategorisi ("other", "home", "school", "job")
    @Published var dueDate: Date? = nil // Teslim tarihi (opsiyonel)
    @Published var thereIsDate: Bool = false // Tarih olup olmadığını belirten bayrak
    @Published var createdAt: TimeInterval = Date().timeIntervalSince1970
    @Published var isCompleted: Bool = false // Görev tamamlanma durumu
    
    init() {}
    
    func save() {
        print("Saved")
        
        guard let uId = FirebaseAuth.Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        
        // `TaskModel` nesnesini oluştur
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
            // `task` modelini JSON formatına çevir ve Firestore'a kaydet
            try db.collection("users")
                .document(uId)
                .collection("tasks")
                .document(id)
                .setData(from: task)
        } catch {
            print("Error saving task: \(error)")
        }
    }
//    init (id: String = UUID().uuidString, title: String, isCompleted: Bool, dueDate: Date) {
//        self.id = id
//        self.title = title
//        self.isCompleted = isCompleted
//        self.dueDate = dueDate
//    }
//    
    
//    func updateCompletion() -> ItemModelV2 {
//        return ItemModelV2(id: id, title: title, isCompleted: !isCompleted, dueDate: dueDate)
//    }
}
