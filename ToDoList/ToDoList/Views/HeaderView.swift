//
//  HeaderView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI

struct HeaderView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let theWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(Color("AccentColor"))
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: theWidth / 2,
                        bottomTrailingRadius: theWidth / 2,
                        topTrailingRadius: 0
                    )
                )
            Image(colorScheme == .dark ? "logo-s" : "logo-b")
                .resizable()
                .frame(width: 150, height: 150)
                .aspectRatio(contentMode: .fit)
                
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
//        .shadow(
//            color: Color("AccentColor").opacity(0.5),
//            radius: 10,
//            x: 0,
//            y: 30)
        .ignoresSafeArea()
    }
}

#Preview {
    HeaderView()
}
