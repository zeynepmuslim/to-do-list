//
//  ListView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI
import ConfettiSwiftUI

struct ListView: View {
    
    private let userId: String
    
    @State private var editMode: EditMode = .inactive
    @EnvironmentObject var listViewModel: ListViewModel
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        ZStack {
            if listViewModel.items.isEmpty {
                NoItemsView()
                    .transition(AnyTransition.opacity.combined(with: .slide).animation(.easeInOut))
            } else {
                List {
                    Section{
                        ForEach(listViewModel.items) { item in
                            ListRowView(item: item)
                                .onTapGesture {
                                    withAnimation(.linear) {
                                        listViewModel.updateItem(item: item)
                                    }
                                }
                                //.listRowBackground(Color.pink)
                        }
                        .onMove(perform: listViewModel.moveItem)
                        .onDelete(perform: listViewModel.deleteItem)
                    }
                   // .foregroundColor(.yellow)
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
//                .background(.white)
                
//                BUNA DÖN
//                .background(editMode == .active ? Color.gray.opacity(0.1) : Color.clear)
            }
        }
        
        .tabItem {
            Label("Tasks", systemImage: "checklist")
        }
        .navigationTitle("Todo List 📝")
        .environment(\.editMode, $editMode) // Bind the EditMode state to the environment
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }) {
                    Text(editMode == .active ? "Done" : "Edit")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Add", destination: AddView())
            }
        }
        .onAppear {
            editMode = .inactive
        }
    }

}

#Preview {
    NavigationView {
        ListView(userId: "dknwdnjkewjk")
    }
    .environmentObject(ListViewModel())
}
