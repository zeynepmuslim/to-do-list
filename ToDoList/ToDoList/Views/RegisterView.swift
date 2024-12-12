//
//  RegisterView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject var registerViewModel = RegisterViewModel()
    
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
                CustomTextField(placeholder: "Full Name", text: $registerViewModel.name)
                
                CustomTextField(placeholder: "Email", text: $registerViewModel.email)
                    .autocapitalization(.none)
                
                CustomTextField(placeholder: "Password", text: $registerViewModel.password, isSecure: true)
                
                CustomButton(title: "Save") {
                    registerViewModel.register()
                    print(registerViewModel.name)
                    print(registerViewModel.email)
                    print(registerViewModel.password)
                }
//                error message
                VStack{
                    if !registerViewModel.errorMessage.isEmpty {
                        Text(registerViewModel.errorMessage)
                            .frame(height: 80)
                            .foregroundColor(.red)
                            .italic()
                    }
                }
                .frame(height: 80)
                
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
