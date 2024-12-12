//
//  CustomCategoryButton.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI

struct CustomCategoryButton: View {
    
    var title: String
    var action: () -> Void
    var backgroundColor: Color = Color("AccentColor")
    var iconName: String
    var theColor: Color
    var textColor: Color = .white
    var theHeight: CGFloat
    var iconFont: Font
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(iconFont)
                Text(title)
                    .font(.callout)
            }
            .frame(height: theHeight)
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(theColor)
            .cornerRadius(10)
          //  .frame(height: 55)
        }
    }
}

#Preview {
    CustomCategoryButton( title: "School", action: {}, iconName: "book.fill", theColor: .red, theHeight: 55, iconFont: .title)
    CustomCategoryButton( title: "School", action: {}, iconName: "gear", theColor: .yellow, theHeight: 55, iconFont: .caption)
    CustomCategoryButton( title: "School", action: {}, iconName: "figure.walk", theColor: .pink, theHeight: 55, iconFont: .callout)
    CustomCategoryButton( title: "School", action: {}, iconName: "pencil", theColor: .red, theHeight: 55, iconFont: .title)
}
