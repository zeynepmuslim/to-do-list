//
//  ListView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct ListView: View {
    @State var selectedTab: String = "School"
    @State var tabs = ["All","Other", "Home", "School", "Job"]
    @State private var editMode: EditMode = .inactive
    @State var selectedTabIcon: String = "plus"
    @State var selectedTabColor: Color = Color.blue
    
    @StateObject var viewModel : ListViewModel
    @FirestoreQuery var items : [TaskModel]
    
    init(userId: String) {
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/tasks")
        self._viewModel = StateObject(wrappedValue: ListViewModel(userId: userId))
    }
    
    var body: some View {
        ZStack {
            if items.isEmpty {
                NoItemsView()
                    .transition(AnyTransition.opacity.combined(with: .slide).animation(.easeInOut))
            } else {
                VStack {
                    CategoryTabs(
                        selectedTab: $selectedTab,
                        tabsWithIconsAndColors: [
                            ("All", "tray.full", Color("AccentColor")),
                            ("Other", "diamond.fill", .red),
                            ("Home", "house.fill", .orange),
                            ("School", "book.fill", .green),
                            ("Job", "briefcase.fill", .blue)
                        ]
                    )
                    .padding(.vertical, 10)
                    
                    //                    CategoryTabs(selectedTab: $selectedTab, tabs: tabs)
                    List(items) { item in
                        ListRowView(item: item, hideCategoryIcon: false)
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    viewModel.delete(id: item.id)
                                }                            }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                }
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
        ListView(userId: "2aOR21qVrORzA82MORSOAtLgyx13")
    }
    //    .environmentObject(ListViewModel())
}
