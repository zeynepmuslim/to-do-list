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
            HStack {
                Image("tick")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .padding(15)
                Text("Task")
                    .fontWeight(.heavy)
                    .font(.system(size: 60))
                Text("Hub")
                    .fontWeight(.light)
                    .font(.system(size: 60))
            }
            .foregroundColor(.white)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
        .ignoresSafeArea()
    }
}

#Preview {
    HeaderView()
}
