//
//  ListView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct ListView: View {
    
    @State private var editMode: EditMode = .inactive
//    @EnvironmentObject var listViewModel: ListViewModel
    
    @FirestoreQuery var items : [TaskModel]
    
    init(userId: String) {
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/tasks")
    }
    
    var body: some View {
        ZStack {
            if items.isEmpty {
                NoItemsView()
                    .transition(AnyTransition.opacity.combined(with: .slide).animation(.easeInOut))
            } else {
                List(items) { item in
                    Text(item.title)
                }
//                List {
//                    Section{
//                        ForEach(listViewModel.items) { item in
//                            ListRowView(item: item)
//                                .onTapGesture {
//                                    withAnimation(.linear) {
//                                        listViewModel.updateItem(item: item)
//                                    }
//                                }
//                                //.listRowBackground(Color.pink)
//                        }
//                        .onMove(perform: listViewModel.moveItem)
//                        .onDelete(perform: listViewModel.deleteItem)
//                    }
//                   // .foregroundColor(.yellow)
//                }
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
        ListView(userId: "2ncgtp9HgEgA8mWl0iduG8mfke43")
    }
//    .environmentObject(ListViewModel())
}
