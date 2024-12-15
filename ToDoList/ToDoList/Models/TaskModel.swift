//
//  TaskModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 13.12.2024.
//


import Foundation

struct TaskModel: Encodable, Decodable, Identifiable,Equatable {
    var id: String
    var title: String
    var priority: String
    var category: String
    var dueDate: TimeInterval?
    var thereIsDate: Bool
    var createdAt: TimeInterval
    var isCompleted: Bool
}
