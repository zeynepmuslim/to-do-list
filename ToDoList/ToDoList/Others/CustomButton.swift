//
//  CustomButton.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//


import SwiftUI

struct CustomButton: View {
    var title: String
    var action: () -> Void
    var backgroundColor: Color = Color("AccentColor")
    var textColor: Color = .white

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(textColor)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(backgroundColor)
                .cornerRadius(10)
        }
    }
}

#Preview {
    CustomButton(title: "Save", action: {})
}
