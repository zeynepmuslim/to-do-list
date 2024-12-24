//
//  DueDateSheet.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 12.12.2024.
//


import SwiftUI

struct DueDateSheet: View {
    @Binding var selectedDate: Date?
    @Binding var dateChanged: Bool
    @Environment(\.dismiss) var dismiss
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    private var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: today)!
    }
    
    @State private var currentDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("set_a_due_date".localized())
                .font(.headline)
                .padding(.top)
                        DatePicker(
                "Select a date",
                selection: $currentDate,
                in: today...,
                displayedComponents: [.date]
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .tint(Color("AccentColor"))
            
            HStack(spacing: 20) {
                Button(action: {
                    currentDate = today
                    selectedDate = currentDate
                    dateChanged = true
                    dismiss()
                }) {
                    Text("today".localized())
                        .font(.headline)
                        .font(.headline)
                         .frame(maxWidth: .infinity)
                         .padding()
                         .foregroundColor(Color("AccentColor"))
                         .background(Color(UIColor.secondarySystemBackground))
                         .cornerRadius(10)
                }
                
                Button(action: {
                    currentDate = tomorrow
                    selectedDate = currentDate
                    dateChanged = true
                    dismiss()
                }) {
                    Text("tomorrow".localized())
                        .font(.headline)
                         .frame(maxWidth: .infinity)
                         .padding()
                         .foregroundColor(Color("AccentColor"))
                         .background(Color(UIColor.secondarySystemBackground))
                         .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
      
            Button(action: {
                selectedDate = currentDate
                dateChanged = true
                dismiss()
            }) {
                Text("save".localized())
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.8)])
    }
}
