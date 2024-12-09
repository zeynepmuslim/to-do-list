//
//  ListView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI
import ConfettiSwiftUI

struct ListView: View {
    @State private var editMode: EditMode = .inactive
    @EnvironmentObject var listViewModel: ListViewModel
    
    var body: some View {
        ZStack {
            if listViewModel.items.isEmpty {
                NoItemsView()
                    .transition(AnyTransition.opacity.animation(.easeIn))
            } else {
                List {
                    ForEach(listViewModel.items) { item in
                        ListRowView(item: item)
                            .onTapGesture {
                                withAnimation(.linear) {
                                    listViewModel.updateItem(item: item)
                                }
                            }
                    }
                    .onMove(perform: listViewModel.moveItem)
                    .onDelete(perform: listViewModel.deleteItem)
                }
                .listStyle(PlainListStyle())
            }
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
        ListView()
    }
    .environmentObject(ListViewModel())
}
