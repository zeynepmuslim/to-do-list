//
//  ListView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI
import ConfettiSwiftUI

struct ListView: View {
    
    @EnvironmentObject var listViewModel: ListViewModel
    
    @State private var counterForConfetti = 0
    @State private var tapPosition: CGPoint = .zero
    
    var body: some View {
        ZStack {
            if listViewModel.items.isEmpty {
                NoItemsView()
                    .transition(AnyTransition.opacity.animation(.easeIn))
            } else {
                List {
                    ForEach(listViewModel.items) { item in
                        ZStack {
                            ListRowView(item: item)
                                .onTapGesture { location in
                                    let globalX = location.x
                                    let globalY = location.y
                                    tapPosition = CGPoint(x: globalX, y: globalY)
                                    counterForConfetti += 1
                                    withAnimation(.linear) {
                                        listViewModel.updateItem(item: item)
                                    }
                                }
                            ConfettiCannon(counter: $counterForConfetti,
                                           num: 15,
                                           colors: [.red, .blue, .green, .yellow, .purple],
                                           rainHeight: 400,
                                           radius: 150)
                                .position(tapPosition)
                        }
                        
                        
                    }
                    .onDelete(perform: listViewModel.deleteItem)
                    .onMove(perform: listViewModel.moveItem)
                    
                }
                .listStyle(PlainListStyle())
            }
        }
        
        .navigationTitle("To Do List 📝")
        .navigationBarItems(
            leading: EditButton(),
            trailing:
                NavigationLink("Add", destination: AddView())
        )
    }
    
    func createConfetti() -> some View {
        ConfettiCannon(counter: $counterForConfetti,
                       num: 15,
                       colors: [.red, .blue, .green, .yellow, .purple],
                       rainHeight: 400,
                       radius: 150)
            .position(tapPosition)
    }
}

#Preview {
    NavigationView {
        ListView()
    }
    .environmentObject(ListViewModel())
}
