//
//  Extansions.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import Foundation
import SwiftUICore

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

extension Date {
    func isWithinPast(minutes: Int) -> Bool {
        let now = Date.now
        let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
        let range = timeAgo...now
        return range.contains(self)
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

extension Bundle {
    private static var bundleKey: UInt8 = 0

    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return }

        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func customLocalizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(Bundle.main, &Bundle.bundleKey) as? Bundle {
            return bundle.customLocalizedString(forKey: key, value: value, table: tableName)
        } else {
            return (self.customLocalizedString(forKey: key, value: value, table: tableName))
        }
    }
}

extension String {
    func localized() -> String {
        let selectedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
        guard let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return self
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

extension View {
    func customNavigation() -> some View {
        self.modifier(CustomNavigationModifier())
    }
}
