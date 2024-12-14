//
//  CategoryTabs.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 13.12.2024.
//

import SwiftUI


struct CategoryTabs: View {
    @Binding var selectedTab: String
    let tabsWithIconsAndColors: [(String, String, Color)] // (Tab İsmi, İkon, Renk)

    var body: some View {
            HStack {
                ForEach(tabsWithIconsAndColors, id: \.0) { tab, icon, color in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { // Animasyon
                            selectedTab = tab
                        }
                    } label: {
                        Image(systemName: icon)
                        .foregroundColor(selectedTab == tab ? .white : color)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: selectedTab == tab ? 50 : 40)
                        .font(selectedTab == tab ? .headline : .callout)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTab == tab ? color : Color.darkerSecond)
                                .shadow(color: selectedTab == tab ? color.opacity(0.5) : .clear, radius: 5, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedTab == tab ? color : .clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    
}

//
//#Preview {
//    @State var previewSelectedTab = "School" // Geçici bir State değişkeni
//
//    return CategoryTabs(
//        selectedTab: $previewSelectedTab, // Binding olarak gönderilir
//        tabsWithIconsAndColors: [
//            ("All", "tray.full", .black),
//            ("Other", "diamond.fill", Color("AccentColor")),
//            ("Home", "house.fill", .orange),
//            ("School", "book.fill", .green),
//            ("Job", "briefcase.fill", .blue)
//        ]
//    )
//}
