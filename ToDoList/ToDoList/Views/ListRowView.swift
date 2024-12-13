//
//  ListRowView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//


import SwiftUI

struct ListRowView: View {
    @StateObject var viewModel = ListRowViewModel()
    
    let item: TaskModel
    let hideCategoryIcon: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Button {
                            viewModel.toggleIsDone(item: item)
                    } label: {
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isCompleted ? .green : .gray)
                            .font(.system(size: 24)) // Adjust size for better visibility
                            .animation(.smooth(duration: 0.4), value: item.isCompleted)// Scale effect for the checkmark
                    }
                    Text(item.title)
                        .font(item.isCompleted ? .subheadline : .headline) // Smaller font when completed
                        .foregroundColor(item.isCompleted ? .secondary : .primary) // Lightened color when completed
                        .strikethrough(item.isCompleted, color: .black) // Add strikethrough when completed
                         // Animate changes
                        .animation(.smooth(duration: 0.5), value: item.isCompleted)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                // Second line of
            }
            Spacer()
            
            HStack(spacing: 10) {
                // Conditionally show category icon
                
                VStack{
                    if item.thereIsDate {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text("\(formattedDate(from: item.dueDate ?? 0))")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                
                if !hideCategoryIcon {
                    Image(systemName: categorySymbol(for: item.category))
                        .foregroundColor(categoryColor(for: item.category))
                        .font(.callout)
                }
                
                // Priority Icon
                Image(systemName: prioritySymbol(for: item.priority))
                    .foregroundColor(priorityColor(for: item.priority))
                    .font(.callout)
                
                // Date (if applicable)
                
                // Info Button
                Button(action: {
                    // Action to show details in a sheet
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    // Helper to format the date into "dd MMM" (e.g., "13 Dec")
    func formattedDate(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    // Helper functions for category and priority symbols/colors
    func categorySymbol(for category: String) -> String {
        switch category {
        case "other": return "diamond.fill"
        case "home": return "house.fill"
        case "school": return "book.fill"
        case "job": return "briefcase.fill"
        default: return "tag"
        }
    }
    
    func categoryColor(for category: String) -> Color {
        switch category {
        case "other": return .red
        case "home": return .orange
        case "school": return .green
        case "job": return .blue
        default: return .red
        }
    }
    
    func prioritySymbol(for priority: String) -> String {
        switch priority {
        case "High": return "star.fill"
        case "Medium": return "star.lefthalf.fill"
        case "Low": return "star"
        default: return "circle"
        }
    }
    
    func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .yellow
        case "Low": return .gray
        default: return .gray
        }
    }
}

#Preview {
    Group {
        ListRowView(item: .init(
            id: "123",
            title: "Test TitleTee sonra nelere geliyo meslee",
            priority: "High",
            category: "job",
            dueDate: Date().timeIntervalSince1970,
            thereIsDate: true,
            createdAt: Date().timeIntervalSince1970,
            isCompleted: true
            
        ), hideCategoryIcon: false)
    }
}
