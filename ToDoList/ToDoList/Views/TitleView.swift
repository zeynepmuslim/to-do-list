//
//  TitleView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 24.12.2024.
//


import SwiftUI

struct TitleView: View {
    let title: String
    let subtitle: String?
    let symbol: String?
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.largeTitle)
                    .fontWeight(.light)
            }
            
            if let symbol = symbol {
                Text(" \(symbol)")
                    .font(.largeTitle)
                    .fontWeight(.light)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
    }
}
