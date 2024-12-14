//
//  ListRowView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI

struct ListRowView: View {
    @StateObject var viewModel = ListRowViewModel()
    @State private var showDetailsSheet = false
    @State var isVisible: Bool = true
    
    var onInfoButtonTap: () -> Void
    let item: TaskModel
    let hideCategoryIcon: Bool
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isCompleted ? .green : .gray)
                        .font(.system(size: 24))
                        .animation(.easeInOut(duration: 0.4), value: item.isCompleted)
                    
                    Text(item.title)
                        .font(item.isCompleted ? .subheadline : .headline)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                        .strikethrough(item.isCompleted, color: .secondary)
                        .animation(.easeInOut(duration: 0.5), value: item.isCompleted)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        if item.thereIsDate {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("\(viewModel.formattedDate(from: item.dueDate ?? 0))")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    if !hideCategoryIcon {
                        Image(systemName: viewModel.categorySymbol(for: item.category))
                            .foregroundColor(viewModel.categoryColor(for: item.category))
                            .font(.callout)
                    }
                    
                    Image(systemName: viewModel.prioritySymbol(for: item.priority))
                        .foregroundColor(viewModel.priorityColor(for: item.priority))
                        .font(.callout)
                }
                .onTapGesture {
                    print("1")
                    viewModel.toggleIsDone(item: item)
                }
                
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .onTapGesture {
//                        withAnimation(.easeInOut(duration: 0.5)) {
                        onInfoButtonTap()
                            showDetailsSheet.toggle()
//                        }
                    }
            }
            
            // NavigationLink ile farklı bir View'e gitme
//            if showDetailsSheet {
//                NavigationLink(destination: DetailView(item: item, onDismiss: $showDetailsSheet)/*, isActive: $showDetailsSheet*/) {
//                    EmptyView() // NavigationLink'in görünür kısmı olmaması için
//                }
//                .transition(.scale)
//                .animation(.easeInOut(duration: 0.5), value: showDetailsSheet)
            }
        }
    }


struct DetailView: View {
    let item: TaskModel
    var onDismiss: () -> Void
//    @Binding var showDetailsSheet: Bool // Geri dönüş için Binding
    @State private var viewOpacity: Double = 0.0 // Başlangıç opaklığı
    @State private var viewScale: CGFloat = 0.9 // Başlangıç ölçeği
    @State private var backgroundOpacity: Double = 0.0 // Arka plan opaklığı
    
    var body: some View {
        ZStack {
            // Arka plan rengi
            Color.white
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeOut(duration: 0.4)) {
                        backgroundOpacity = 1.0
                    }
                }
            
            VStack {
                Text("Detay Sayfası")
                    .font(.largeTitle)
                    .padding()
                
                Text("Görev: \(item.title)")
                    .font(.headline)
                    .padding()
                
                if let dueDate = item.dueDate {
                    Text("Tarih: \(Date(timeIntervalSince1970: dueDate).formatted())")
                        .font(.subheadline)
                }
                
                Spacer()
                
                Button(action: {
                    // Geri dön
                    onDismiss()
//                    showDetailsSheet = false
                }) {
                    Text("Geri Dön")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .scaleEffect(viewScale)
            .opacity(viewOpacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) {
                    viewOpacity = 1.0
                    viewScale = 1.0
                }
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        ListRowView(item: .init(
//            id: "123",
//            title: "Test Title",
//            priority: "Medium",
//            category: "job",
//            dueDate: Date().timeIntervalSince1970,
//            thereIsDate: true,
//            createdAt: Date().timeIntervalSince1970,
//            isCompleted: false
//        ), hideCategoryIcon: false, onInfoButtonTap: {})
//    }
//}
