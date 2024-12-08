//
//  ItemModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import Foundation

struct ItemModel: Identifiable, Codable {
    let id: String = UUID().uuidString
    let title: String
    let isCompleted: Bool
}
