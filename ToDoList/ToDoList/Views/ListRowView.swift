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
    
    @Environment(\.colorScheme) var colorScheme
    
    var onInfoButtonTap: () -> Void
    let item: TaskModel
    let hideCategoryIcon: Bool
    
    var body: some View {
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
                    .foregroundColor(Color("darkerSecond"))
                
                if let dueDate = item.dueDate {
                    let dueDateStatus = viewModel.getDueDateStatus(from: dueDate, isCompleted: item.isCompleted)
                    
                    VStack {
                        if let status = dueDateStatus {
                            if !(status.text == "overdue".localized() && item.isCompleted) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(colorScheme == .dark ? .clear : Color(status.color.opacity(0.3)))
                                        .frame(height: 7)
                                        .padding(.horizontal, -4)
                                    Text(status.text)
                                        .foregroundColor(colorScheme == .dark ? Color(status.color) : .black)
                                        .font(.caption)
                                        .bold()
                                        .lineLimit(1)
                                }
                                HStack(alignment: .center,spacing: 2) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    Text("\(viewModel.formattedDate(from: item.dueDate ?? 0))")
                                        .foregroundColor(.gray)
                                        .font(.caption)                                }
                            }
                        } else {
                            HStack(alignment: .bottom) {
                                Spacer()
                                VStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                    Text("\(viewModel.formattedDate(from: item.dueDate ?? 0))")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 70)
                }
                
                if !hideCategoryIcon {
                    Image(systemName: viewModel.categorySymbol(for: item.category, isCompleted: item.isCompleted))
                        .foregroundColor(viewModel.categoryColor(for: item.category, isCompleted: item.isCompleted))
                        .font(.callout)
                }
                
                Image(systemName: viewModel.prioritySymbol(for: item.priority, isCompleted: item.isCompleted))
                    .foregroundColor(viewModel.priorityColor(for: item.priority, isCompleted: item.isCompleted))
                    .font(.callout)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.toggleIsDone(item: item)
            }
            
            Image(systemName: "info.circle")
                .foregroundColor(item.isCompleted ? .gray : .blue)
                .onTapGesture {
                    onInfoButtonTap()
                    showDetailsSheet.toggle()
                }
        }
        
    }
}

