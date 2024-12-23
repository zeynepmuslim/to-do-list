//
//  CategoryTabs.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 13.12.2024.
//

import SwiftUI

struct CategoryTabs: View {
    @Binding var selectedTab: String
    let tabsWithIconsAndColors: [(String, String, Color)]
    
    var body: some View {
        HStack {
            ForEach(tabsWithIconsAndColors, id: \.0) { tab, icon, color in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
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
                        )
                }
            }
        }
        .padding(.horizontal)
    }
    
}
