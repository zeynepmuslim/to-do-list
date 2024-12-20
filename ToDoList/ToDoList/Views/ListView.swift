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
    @State private var showDeleteAllAlert = false // Alert kontrolü
    
    @State private var sortOption: SortOption = .createdAt// Replace with your data source
    
    enum SortOption: String, CaseIterable {
            case title, createdAt, dueDate, priority, category
        var title: String {
            switch self {
            case .title: return "Title"
            case .createdAt: return "Created Date"
            case .dueDate: return "Due Date"
            case .priority: return "Priority"
            case .category: return "Category"
            }
        }
        
        // Özel icon
        var icon: String {
            switch self {
            case .title: return "textformat"
            case .createdAt: return "calendar"
            case .dueDate: return "clock"
            case .priority: return "exclamationmark.triangle"
            case .category: return "folder"
            }
        }
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
                    HStack(spacing: 0) {
                        Text("Task")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Hub")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal,20)
                    .padding(.top, 15)
                    NoItemsView()
                        .transition(AnyTransition.opacity.combined(with: .slide).animation(.easeInOut))
                    
                }
            } else {
                VStack {
                    HStack(spacing: 0) {
                        Text("Task")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        Text("Hub 📝")
                            .font(.largeTitle)
                            .fontWeight(.light)
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
                    
                    if sortedTasks.isEmpty {
                                       VStack(spacing: 20) {
                                           Image(systemName: "tray")
                                               .font(.system(size: 50))
                                               .foregroundColor(.gray)
                                           Text("No items in this category")
                                               .font(.headline)
                                               .foregroundColor(.gray)
                                       }
                                       .frame(maxWidth: .infinity, maxHeight: .infinity)
                                       .padding(.top, 50)
                    } else {
                        List {
                            if !sortedTasks.filter({ !$0.isCompleted }).isEmpty {
                                {
                                    ForEach(sortedTasks.filter { !$0.isCompleted }) { item in
                                        ListRowView(
                                            onInfoButtonTap: {
                                                selectedItem = item
                                                navigateToDetail = true
                                            },
                                            item: item,
                                            hideCategoryIcon: false
                                        )
                                        .listRowBackground(Color("darkerSecond"))
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
                                Section(header: HStack {
                                    Text("Completed")
                                    Spacer()
                                    Button(action: {
                                        // Tamamlanan tüm görevleri sil
                                        showDeleteAllAlert = true
                                    }) {
                                        Text("Delete All")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }) {
                                    ForEach(sortedTasks.filter { $0.isCompleted }) { item in
                                        ListRowView(
                                            onInfoButtonTap: {
                                                selectedItem = item
                                                navigateToDetail = true
                                                triggerHapticFeedback(type: .success)
                                            },
                                            item: item,
                                            hideCategoryIcon: false
                                        )
                                        .listRowBackground(Color("darkerSecond"))
                                        .swipeActions {
                                            Button("Delete", role: .destructive) {
                                                triggerHapticFeedback(type: .warning)
                                                viewModel.delete(id: item.id)
                                            }
                                        }
                                    }
                                }
                                .alert("Delete All Completed Tasks?", isPresented: $showDeleteAllAlert) {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Delete", role: .destructive) {
                                        
                                        withAnimation {
                                            for item in sortedTasks.filter({ $0.isCompleted }) {
                                                viewModel.delete(id: item.id)
                                            }
                                        }
                                    }
                                } message: {
                                    Text("This action cannot be undone. Are you sure you want to delete all completed tasks?")
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .scrollContentBackground(.hidden)
                        .listStyle(InsetGroupedListStyle())
                    }
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
    
    
    func triggerHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}





#Preview {
    NavigationView {
        ListView(userId: "2aOR21qVrORzA82MORSOAtLgyx13")
    }
    //    .environmentObject(ListViewModel())
}
