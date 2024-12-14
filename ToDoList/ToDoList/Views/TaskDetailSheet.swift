//
//  TaskDetailSheet.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 14.12.2024.
//
import Foundation
import SwiftUI

struct TaskDetailSheet: View {
    @StateObject var viewModel = ListRowViewModel()
    let myIcon = Image(systemName: "star.fill")
    
    let item: TaskModel
    
    var body: some View {
        VStack {
            if item.isCompleted {
                Text("Completed Task ✨")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            Text(item.title)
                .font(.headline)
                .padding()
            HStack (alignment: .bottom){
                Spacer()
                VStack{
                    Image(systemName: viewModel.categorySymbol(for: item.category))
                        .foregroundColor(viewModel.categoryColor(for: item.category))
//                        .font(.title)
                    Text("Category")
                        .foregroundStyle(.secondary)
                        .padding(5)
                        .font(.subheadline)
                }
                Spacer()
                VStack{
                    HStack{
                        if item.priority == "Low" {
                            myIcon
                                .foregroundColor(viewModel.priorityColor(for: item.priority))
                        } else if item.priority == "Medium" {
                            Group{
                                myIcon
                                myIcon
                            }
                            .foregroundColor(viewModel.priorityColor(for: item.priority))
                        } else if item.priority == "High" {
                            Group{
                                myIcon
                                myIcon
                                myIcon
                            }
                            .foregroundColor(viewModel.priorityColor(for: item.priority))
                        }
                    }
//                        .font(.title)
                    
                    Text("Priority: \(item.priority)")
                        .foregroundStyle(.secondary)
                        .padding(5)
                        .font(.subheadline)
                    
                }
                Spacer()
                VStack{
                    if item.thereIsDate {
                        Text(viewModel.formattedDateLong(from: item.dueDate ?? 0))
                            .font(.footnote)
                        Text("Due Date")
                            .foregroundStyle(.secondary)
                            .padding(5)
                            .font(.subheadline)
                    } else {
                        Text("There is no due date")
                            .foregroundStyle(.secondary)
                            .padding(5)
                            .font(.subheadline)
                    }
                }
                .multilineTextAlignment(.center)
                Spacer()
            }
           
            if !item.isCompleted {
                    
                HStack {
                    Button{
                        
                    } label: {
                        Text("Mark as Completed 🎉")
                            .font(.headline)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
    }
}

