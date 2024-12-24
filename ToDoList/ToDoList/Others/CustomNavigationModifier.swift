//
//  CustomNavigationModifier.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 24.12.2024.
//
import SwiftUI
import Foundation

struct CustomNavigationModifier: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("back_button".localized())
                        }
                    }
                }
            }
    }
}
