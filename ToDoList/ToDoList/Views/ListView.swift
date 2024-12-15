//
//  ListView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct ListView: View {
    
    let theWidth = UIScreen.main.bounds.width
    @State var selectedTab: String = "all"
    @State var tabs = ["all","other", "home", "school", "job"]
    @State private var editMode: EditMode = .inactive
    @State var selectedTabIcon: String = "plus"
    @State var selectedTabColor: Color = Color.blue
    
    @State private var showOverlay = false
    @State private var navigateToDetail = false
    @State private var selectedItem: TaskModel? = nil
    
    @StateObject var viewModel : ListViewModel
    @FirestoreQuery var items : [TaskModel]
    @State private var isVisible: Bool = false
    
    init(userId: String) {
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/tasks")
        self._viewModel = StateObject(wrappedValue: ListViewModel(userId: userId))
    }
    
    var filteredItems: [TaskModel] {
        if selectedTab == "all" {
            return items
        }
        return items.filter { $0.category == selectedTab }
    }
    
    var body: some View {
        ZStack {
            HStack{
                Spacer()
                VStack{
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
                        .frame(width: theWidth / 2.5, height: theWidth / 2.5 )
                        .offset(y: -40)
                    
                    Spacer()
                    
                }
                
            }
            if items.isEmpty {
                VStack{
                    HStack {
                        Text("Todo List 📝")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        Spacer()
                    }
                    .padding(.horizontal,20)
                    .padding(.top, 15)
                    NoItemsView()
                        .transition(AnyTransition.opacity.combined(with: .slide).animation(.easeInOut))
                    
                }
            } else {
                VStack {
                    HStack {
                        Text("Todo List 📝")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        Spacer()
                    }
                    .padding(.horizontal,20)
                    .padding(.top, 15)
                    CategoryTabs(
                        selectedTab: $selectedTab,
                        tabsWithIconsAndColors: [
                            ("all", "tray.full", Color("AccentColor")),
                            ("other", "diamond.fill", .red),
                            ("home", "house.fill", .orange),
                            ("school", "book.fill", .green),
                            ("job", "briefcase.fill", .blue)
                        ]
                    )
                    .padding(.vertical, 10)
                    
                    
                    List(filteredItems) { item in
                        ListRowView(onInfoButtonTap: {
                            selectedItem = item
                            navigateToDetail = true
                        }, item: item, hideCategoryIcon: false)
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                viewModel.delete(id: item.id)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: AddView()) {
                        Image(systemName: "plus")
                            .frame(width: 60, height: 60)
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color("AccentColor")))
                            .shadow(
                                color: Color("AccentColor").opacity(0.5),
                                radius: 20,
                                x: 0,
                                y: 10)
                    }
                    
                }
                .padding(30)
            }
        
            if let selectedItem = selectedItem {
                NavigationLink(
                    destination: EditView(item: selectedItem, selectedPriority: selectedItem.priority, selectedCategory: selectedItem.category),
                    isActive: $navigateToDetail,
                    label: { EmptyView() }
                )
                
            }
//                NavigationLink(
//                    destination: EditView(item: ????, onDismiss: {
//                        showOverlay = false
//                        navigateToDetail = false
//                    }/*, showDetailsSheet: Binding<Bool> */),
//                    isActive: $navigateToDetail
////                )
//                {
//                    EmptyView()
//                }
            }.toolbar(.hidden, for: .navigationBar)
        }
        
    }
    
    



#Preview {
    NavigationView {
        ListView(userId: "2aOR21qVrORzA82MORSOAtLgyx13")
    }
    //    .environmentObject(ListViewModel())
}
