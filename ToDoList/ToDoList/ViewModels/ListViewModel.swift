//
//  ListViewModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import Foundation

class ListViewModel: ObservableObject {
    
    @Published var items: [ItemModel] = [] {
        didSet { //call it everytime items is updated
            saveItem()
        }
    }
    let itemsKey:String = "items_list"
    
    init() {
        getItems()
    }
    
    func getItems() {
        
        guard
            let data = UserDefaults.standard.data(forKey: itemsKey),
            let savedItems = try? JSONDecoder().decode([ItemModel].self, from: data)
        else { return }
        
        self.items = savedItems
//        let newItems = [
//            ItemModel(title: "First Task", isCompleted: false),
//            ItemModel(title: "Second Task", isCompleted: true),
//            ItemModel(title: "Third Task", isCompleted: false)
//        ]
//        items.append(contentsOf: newItems)
    }
    
    func deleteItem(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
    
    func moveItem(from: IndexSet, to: Int) {
        items.move(fromOffsets: from, toOffset: to)
    }
    
    func addItem(title: String) {
        let newitem = ItemModel(title: title, isCompleted: false)
        items.append(newitem)
    }
    
    func updateItem(item: ItemModel) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item.updateCompletion()
        }
    }
    
    func saveItem() {
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: itemsKey)
        }
    }
}
