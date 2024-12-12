//
//  AddView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI


struct AddView: View {
    @State var textFieldText: String = ""
    @State var selectedPriority: String = "Low"
    @State var selectedCategory: String = "other"
    @State var customCategories: Array = ["other", "home", "school", "job"]
    @State var thereIsDate: Bool = false
    @State var selectedDate: Date? = nil
    @State var showAlert: Bool = false
    @State var alertTitle: String = ""
    
    @State var animate: Bool = false
    
    @State var showDateSheet: Bool = false // Sheet kontrolü için

    struct Category: Identifiable {
        let id = UUID()
        var name: String
        var color: Color
        var icon: String
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Task Title
                Text("Task Title")
                    .font(.headline)
                CustomTextField(placeholder: "Type something here...", text: $textFieldText, isSecure: false)
                
                // Task Priority
                Text("Task Priority")
                    .font(.headline)
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(["Low", "Medium", "High"], id: \.self) { priority in
                        Text(priority)
                            .tag(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("Task Category")
                    .font(.headline)
                HStack(alignment: .center) {
                    CustomCategoryButton(title: "Other", action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedCategory = "other"
                        }
                        
                        print("Other button tapped")
                    }, iconName: "diamond.fill",
                                         theColor: selectedCategory == "other" ? .gray : .gray.opacity(0.5),
                                         theHeight: selectedCategory == "other" ? 55 : 40,
                                         iconFont: selectedCategory == "other" ? .title : .callout
                    
                    )
                    .shadow(
                        color: selectedCategory == "other" ? .gray.opacity(0.7) : .gray.opacity(0.0),
                        radius: selectedCategory == "other" ? 0 : 30)
                    
                    CustomCategoryButton(title: "Home", action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedCategory = "home"
                        }
                        print("home button tapped")
                    }, iconName: "house.fill",
                                         theColor: selectedCategory == "home" ? .orange : .orange.opacity(0.5),
                                         theHeight: selectedCategory == "home" ? 55 : 40,
                                         iconFont: selectedCategory == "home" ? .title : .callout
                    )
                    .shadow(
                        color: selectedCategory == "home" ? .orange.opacity(0.7) : .orange.opacity(0.0),
                        radius: selectedCategory == "home" ? 0 : 30)
                    
                    CustomCategoryButton(title: "School", action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedCategory = "school"
                        }
                        print("school button tapped")
                    }, iconName: "book.fill",
                                         theColor: selectedCategory == "school" ? .green : .green.opacity(0.5),
                                         theHeight: selectedCategory == "school" ? 55 : 40,
                                         iconFont: selectedCategory == "school" ? .title : .callout
                    )
                    .shadow(
                        color: selectedCategory == "school" ? .green.opacity(0.7) : .green.opacity(0.0),
                        radius: selectedCategory == "school" ? 0 : 30)
                    
                    CustomCategoryButton(title: "Job", action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedCategory = "job"
                        }
                        print("job button tapped")
                    }, iconName: "briefcase.fill",
                                         theColor: selectedCategory == "job" ? .blue : .blue.opacity(0.5),
                                         theHeight: selectedCategory == "job" ? 55 : 40,
                                         iconFont: selectedCategory == "job" ? .title : .callout
                    )
                    .shadow(
                        color: selectedCategory == "job" ? .blue.opacity(0.7) : .blue.opacity(0.0),
                        radius: selectedCategory == "job" ? 0 : 30)
                }
//
                
                // Due Date Toggle
                Toggle(isOn: Binding(
                    get: { thereIsDate },
                    set: { newValue in
                        thereIsDate = newValue
                        if newValue {
                            showDateSheet = true // Toggle açık olduğunda sheet göster
                        }
                    }
                )) {
                    Text("Would you like to set a due date?")
                        .font(.headline)
                }
                .padding(.vertical)
                
                Spacer()
                
                // Save Button
                CustomButton(title: "Save") {
                    saveButtonPressed()
                }
            }
            .padding()
        }
        .navigationTitle("Add an Item ✏️")
        .sheet(isPresented: $showDateSheet) {
            DueDateSheet(selectedDate: $selectedDate)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle))
        }
    }
    
    func saveButtonPressed() {
        if textIsAppropriate() {
            let newTask = [
                "title": textFieldText,
                "priority": selectedPriority,
                "category": selectedCategory,
                "dueDate": selectedDate,
                "thereIsDate": thereIsDate
            ] as [String: Any]
            
            print(newTask) // Firebase işlemleri buraya eklenebilir
        }
    }
    
    func textIsAppropriate() -> Bool {
        if textFieldText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertTitle = "Task title cannot be empty!"
            showAlert.toggle()
            return false
        }
        return true
    }
}
#Preview {
        NavigationView {
            AddView()
        }
        .preferredColorScheme(.light)
        .environmentObject(ListViewModel())
}
