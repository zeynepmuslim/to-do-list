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
    
    @State private var sortOption: SortOption = .createdAt// Replace with your data source
    
    enum SortOption: String, CaseIterable {
            case title, createdAt, dueDate, priority, category
        }
    init(userId: String) {
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/tasks")
        self._viewModel = StateObject(wrappedValue: ListViewModel(userId: userId))
    }
    var sortedTasks: [TaskModel] {
           let tab = selectedTab
           let filtered = tab == "all" ? viewModel.items : viewModel.items.filter { $0.category == tab }
           return filtered.sorted {
               switch sortOption {
               case .title: return $0.title < $1.title
               case .createdAt: return $0.createdAt > $1.createdAt
               case .dueDate:
                   let date1 = $0.dueDate ?? .greatestFiniteMagnitude
                   let date2 = $1.dueDate ?? .greatestFiniteMagnitude
                   return date1 < date2
               case .priority:
                   let priorityOrder: [String: Int] = ["High": 1, "Medium": 2, "Low": 3]
                   return (priorityOrder[$0.priority] ?? 4) < (priorityOrder[$1.priority] ?? 4)
               case .category: return $0.category < $1.category
               }
           }
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
                    
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    List {
                        // To-Do Listesi
                        if !sortedTasks.filter({ !$0.isCompleted }).isEmpty {
                            Section(header: Text("To-Do")) {
                                ForEach(sortedTasks.filter { !$0.isCompleted }) { item in
                                    ListRowView(
                                        onInfoButtonTap: {},
                                        item: item,
                                        hideCategoryIcon: false
                                    )
                                    .swipeActions {
                                        Button("Delete", role: .destructive) {
                                            viewModel.delete(id: item.id)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Completed Listesi
                        if !sortedTasks.filter({ $0.isCompleted }).isEmpty {
                            Section(header: Text("Completed")) {
                                ForEach(sortedTasks.filter { $0.isCompleted }) { item in
                                    ListRowView(
                                        onInfoButtonTap: {},
                                        item: item,
                                        hideCategoryIcon: false
                                    )
                                    .swipeActions {
                                        Button("Delete", role: .destructive) {
                                            viewModel.delete(id: item.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                                .listStyle(InsetGroupedListStyle())
                } .animation(.easeInOut(duration: 0.3), value: items)
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
            
        }
            .onAppear{
                print("listeler")
            }
    }
    
}





#Preview {
    NavigationView {
        ListView(userId: "2aOR21qVrORzA82MORSOAtLgyx13")
    }
    //    .environmentObject(ListViewModel())
}
