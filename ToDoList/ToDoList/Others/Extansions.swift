//
//  Extansions.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import Foundation

extension Encodable {
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}
