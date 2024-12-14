//
//  ListRowView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//


import SwiftUI

struct ListRowView: View {
    @StateObject var viewModel = ListRowViewModel()
    @State private var showDetailsSheet = true
    let item: TaskModel
    let hideCategoryIcon: Bool
    
    var body: some View {
        HStack {
            HStack{
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .font(.system(size: 24)) // Adjust size for better visibility
                    .animation(.smooth(duration: 0.4), value: item.isCompleted)// Scale effect for the checkmark
                
                Text(item.title)
                    .font(item.isCompleted ? .subheadline : .headline)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                    .strikethrough(item.isCompleted, color: .secondary)
                    .animation(.smooth(duration: 0.5), value: item.isCompleted)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack{
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
                    print("2")
                    print(item.title)
                    showDetailsSheet = true
                }
            
        }.sheet(isPresented: $showDetailsSheet) {
            TaskDetailSheet(item: item)
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
            
        }
        
    }
    
}


#Preview {
    Group {
        ListRowView(item: .init(
            id: "123",
            title: "Test TitleTee sonra ok jnıjnjıknklnmjk ıjnı lelere geliyo meslee",
            priority: "Medium",
            category: "job",
            dueDate: Date().timeIntervalSince1970,
            thereIsDate: false,
            createdAt: Date().timeIntervalSince1970,
            isCompleted: true
            
        ), hideCategoryIcon: false)
    }
}
