//
//  UserModel.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import Foundation

struct UserModel: Codable {
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
}
