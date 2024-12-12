//
//  RegisterView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI

struct RegisterView: View {
    
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    let theWidth = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var body: some View {
        VStack {
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(Color("AccentColor"))
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: theWidth,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                    )
                    .ignoresSafeArea()
                    .frame(width: theWidth / 2, height: theWidth / 2 )
                    .offset(y: -30)
            }
            
            VStack(spacing: 10) {
                CustomTextField(placeholder: "Full Name", text: $name)
                
                CustomTextField(placeholder: "Email", text: $email)
                
                CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                
                CustomButton(title: "Save") {
                    print(name)
                    print(email)
                    print(password)
                }
                
            }
            .padding(.horizontal, 40)
            .padding(.top, 70)
            Spacer()
        }
    }
}

#Preview {
    RegisterView()
}
