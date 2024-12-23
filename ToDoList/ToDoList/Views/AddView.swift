//
//  AddView.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 9.12.2024.
//

import SwiftUI


struct AddView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var ItemModel = ItemModelV2()
    @State var selectedPriority: String = "Low"
    @State var selectedCategory: String = "other"
    @State var customCategories: Array = ["other", "home", "school", "job"]
    @State var taskPriority: Array = ["Low", "Medium", "High"]
    @State var selectedDate: Date? = nil
    @State var showAlert: Bool = false
    @State var alertTitle: String = ""
    @State var dateChanged: Bool = false
    @State var animate: Bool = false
    @State var showDateSheet: Bool = false
    
    var darkerSecond = Color("DarkerSecond")
    let myIcon = Image(systemName: "star.fill")
    
    private let characterLimit = 100
    
    struct Category: Identifiable {
        let id = UUID()
        var name: String
        var color: Color
        var icon: String
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Task Title")
                    .font(.headline)
                
                CustomTextField(placeholder: "Type something here...", text: $ItemModel.title, isSecure: false)
                    .submitLabel(.continue)
                    .onSubmit {
                        hideKeyboard()
                    }
                
                    .onChange(of: ItemModel.title) { newValue in
                        if newValue.count > characterLimit {
                            ItemModel.title = String(newValue.prefix(characterLimit))
                        }
                    }
                
                Text("\(ItemModel.title.count)/\(characterLimit) characters")
                    .font(.footnote)
                    .foregroundColor(ItemModel.title.count >= characterLimit ? .red : .secondary)
                
                HStack {
                    Text("Task Priority")
                        .font(.headline)
                    Spacer()
                    if selectedPriority == "Low" {
                        Group {
                            myIcon                        }
                        .foregroundColor(.green)
                        .transition(.scale)
                        Text("😌")
                            .transition(.opacity)
                    } else if selectedPriority == "Medium" {
                        Group {
                            myIcon
                            myIcon
                        }
                        .foregroundColor(.yellow)
                        .transition(.scale)
                        Text("😬")
                            .transition(.opacity)
                    } else {
                        Group {
                            myIcon
                            myIcon
                            myIcon
                        }
                        .foregroundColor(.red)
                        .transition(.scale)
                        Text("🤯")
                            .transition(.opacity)
                    }
                }
                .padding(.top,10)
                .animation(.easeInOut, value: selectedPriority)
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(taskPriority, id: \.self) { priority in
                        Text(priority)
                            .tag(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("Task Category")
                    .font(.headline)
                    .padding(.top,10)
                
                HStack(alignment: .center) {
                    CustomCategoryButton(title: "Other", action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedCategory = "other"
                        }
                        
                        print("Other button tapped")
                    }, iconName: "diamond.fill",
                                         theColor: selectedCategory == "other" ? .red : .darkerSecond,
                                         theHeight: selectedCategory == "other" ? 55 : 40,
                                         iconFont: selectedCategory == "other" ? .title : .callout,
                                         fontColor: selectedCategory == "other" ? .white : .gray
                    )
                    .shadow(
                        color: selectedCategory == "other" ? .red.opacity(0.7) : .gray.opacity(0.0),
                        radius: selectedCategory == "other" ? 0 : 30)
                    
                    CustomCategoryButton(title: "Home", action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedCategory = "home"
                        }
                        print("home button tapped")
                    }, iconName: "house.fill",
                                         theColor: selectedCategory == "home" ? .orange : .darkerSecond,
                                         theHeight: selectedCategory == "home" ? 55 : 40,
                                         iconFont: selectedCategory == "home" ? .title : .callout,
                                         fontColor: selectedCategory == "home" ? .white : .gray
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
                                         theColor: selectedCategory == "school" ? .green : .darkerSecond,
                                         theHeight: selectedCategory == "school" ? 55 : 40,
                                         iconFont: selectedCategory == "school" ? .title : .callout,
                                         fontColor: selectedCategory == "school" ? .white : .gray
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
                                         theColor: selectedCategory == "job" ? .blue : .darkerSecond,
                                         theHeight: selectedCategory == "job" ? 55 : 40,
                                         iconFont: selectedCategory == "job" ? .title : .callout,
                                         fontColor: selectedCategory == "job" ? .white : .gray
                    )
                    .shadow(
                        color: selectedCategory == "job" ? .blue.opacity(0.7) : .blue.opacity(0.0),
                        radius: selectedCategory == "job" ? 0 : 30)
                }
                
                
                if let selectedDate = selectedDate {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Selected Due Date")
                                .font(.headline)
                            Text(selectedDate, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            showDateSheet = true
                        } label: {
                            Text("Change")
                                .padding(.horizontal, 15)
                                .frame(height: 40)
                                .background(.darkerSecond)
                                .cornerRadius(10)
                                .foregroundColor(Color("AccentColor"))
                        }
                        Button {
                            withAnimation {
                                self.selectedDate = nil
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical)
                } else {
                    
                    HStack {
                        Text("Do you have a deadline?")
                            .font(.headline)
                        Spacer()
                        Button {
                            showDateSheet = true
                        } label: {
                            Text("Set a Due Date")
                                .padding(.horizontal, 15)
                                .frame(height: 40)
                                .background(.darkerSecond)
                                .cornerRadius(10)
                                .foregroundColor(Color("AccentColor"))
                            
                        }
                    }
                    .padding(.vertical)
                }
                
                Spacer()
                
                CustomButton(title: "Create Task") {
                    saveButtonPressed()
                }
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .padding(.horizontal, 15)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.darkerSecond)
                        .cornerRadius(10)
                        .foregroundColor(Color("AccentColor"))
                }
                
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Close") {
                    hideKeyboard()
                }
                .foregroundColor(Color("AccentColor"))
            }
        }
        .sheet(isPresented: $showDateSheet) {
            DueDateSheet(selectedDate: $selectedDate, dateChanged: $dateChanged)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle))
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func saveButtonPressed() {
        if textIsAppropriate() {
            ItemModel.priority = selectedPriority
            ItemModel.category = selectedCategory
            if let selectedDate = selectedDate {
                ItemModel.dueDate = selectedDate
                ItemModel.thereIsDate = true
            }
            
            ItemModel.save()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func triggerHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func textIsAppropriate() -> Bool {
        let trimmedText = ItemModel.title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            alertTitle = "Task title cannot be empty!"
            showAlert.toggle()
            triggerHapticFeedback(type: .error)
            return false
        }
        
        if trimmedText.count < 3 {
            alertTitle = "Task title must be at least 3 characters long!"
            showAlert.toggle()
            triggerHapticFeedback(type: .error)
            return false
        }
        
        triggerHapticFeedback(type: .success)
        return true
    }
}
#Preview {
    NavigationView {
        AddView()
    }
    .preferredColorScheme(.light)
}
