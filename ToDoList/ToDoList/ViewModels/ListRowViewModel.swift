//
//  ListRowViewModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 13.12.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
}
