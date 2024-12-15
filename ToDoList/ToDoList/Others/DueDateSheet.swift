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
    @Environment(\.dismiss) var dismiss // Sheet'i kapatmak için
    
    // Bugün ve yarın için dinamik kısayollar
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    private var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: today)!
    }
    
    // Seçilen tarihi kontrol etmek için geçerli tarih
    @State private var currentDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set Due Date")
                .font(.headline)
                .padding(.top)
            
            // Tarih seçici (Date Picker Wheel)
            DatePicker(
                "Select a date",
                selection: $currentDate,
                in: today...,
                displayedComponents: [.date]
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .tint(Color("AccentColor")) // Tint rengini uygulama
            
            // Bugün ve Yarın kısayol düğmeleri
            HStack(spacing: 20) {
                Button(action: {
                    currentDate = today
                    selectedDate = currentDate
                    dateChanged = true
                    dismiss()
                }) {
                    Text("Today")
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
                    Text("Tomorrow")
                        .font(.headline)
                         .frame(maxWidth: .infinity)
                         .padding()
                         .foregroundColor(Color("AccentColor"))
                         .background(Color(UIColor.secondarySystemBackground))
                         .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Kaydet düğmesi
            Button(action: {
                selectedDate = currentDate
                dateChanged = true
                dismiss() // Sheet'i kapat
            }) {
                Text("Save")
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
        .presentationDetents([.fraction(0.8)]) // Alttan çıkan, sayfayı kaplamayan bir Sheet
    }
}

//#Preview {
//    DueDateSheet(selectedDate: Date?) {
//        
//    }
//}
