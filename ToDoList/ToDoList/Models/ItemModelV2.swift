//
//  ItemModelV2.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import Foundation

class ItemModelV2: ObservableObject {
    @Published var title = ""
//    @Published var isCompleted: Bool
    @Published var dueDate = Date()
    
    init() {}
    
    func save() {
        
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
