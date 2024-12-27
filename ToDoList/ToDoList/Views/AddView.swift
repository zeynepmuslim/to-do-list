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
    @Environment(\.colorScheme) var colorScheme
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
        var key = "other"
        var iconName: String
        var color: Color
    }
    
    let categories: [Category] = [
        Category(key: "other", iconName: "diamond.fill", color: .red),
        Category(key: "home", iconName: "house.fill", color: .orange),
        Category(key: "school", iconName: "book.fill", color: .green),
        Category(key: "job", iconName: "briefcase.fill", color: .blue)
    ]

    let taskPriorities: [(key: String, localizedKey: String, iconCount: Int, color: Color, emoji: String)] = [
        (key: "Low", localizedKey: "low", iconCount: 1, color: .green, emoji: "😌"),
        (key: "Medium", localizedKey: "medium", iconCount: 2, color: .yellow, emoji: "😬"),
        (key: "High", localizedKey: "high", iconCount: 3, color: .red, emoji: "🤯")
    ]
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("task_title".localized())
                        .font(.headline)
                    
                    CustomTextField(placeholder: "type_something_here".localized(), text: $ItemModel.title, isSecure: false)
                        .submitLabel(.continue)
                        .onSubmit {
                            hideKeyboard()
                        }
                        .onChange(of: ItemModel.title) { newValue in
                            if newValue.count > characterLimit {
                                ItemModel.title = String(newValue.prefix(characterLimit))
                            }
                        }
                    
                    Text("\(ItemModel.title.count)/\(characterLimit) " + "characters".localized())
                        .font(.footnote)
                        .foregroundColor(ItemModel.title.count >= characterLimit ? .red : .secondary)
                    
                    PriorityView(selectedPriority: $selectedPriority, priorities: taskPriorities)
                    
                    Text("category".localized())
                        .font(.headline)
                        .padding(.top,10)
                    
                    HStack(alignment: .center) {
                        ForEach(categories, id: \.key) { category in
                            CustomCategoryButton(
                                title: category.key.localized(),
                                action: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        selectedCategory = category.key
                                    }
                                },
                                iconName: category.iconName,
                                theColor: selectedCategory == category.key ? category.color : .darkerSecond,
                                theHeight: selectedCategory == category.key ? 55 : 40,
                                iconFont: selectedCategory == category.key ? .title : .callout,
                                fontColor: selectedCategory == category.key ? .white : .gray
                            )
                            .shadow(
                                color: selectedCategory == category.key ? category.color.opacity(0.5) : category.color.opacity(0.0),
                                radius: selectedCategory == category.key ? 15 : 0
                            )
                        }
                    }
                    if let selectedDate = selectedDate {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("selected_due_date".localized())
                                    .font(.headline)
                                Text(selectedDate, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                showDateSheet = true
                            } label: {
                                Text("change".localized())
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
                            Text("do_you_have_a_deadline".localized())
                                .font(.headline)
                            Spacer()
                            Button {
                                showDateSheet = true
                            } label: {
                                Text("set_a_due_date".localized())
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
                    
                    CustomButton(title: "create_task".localized()) {
                        saveButtonPressed()
                    }
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        triggerHapticFeedback(type: .warning)
                    } label: {
                        Text("cancel".localized())
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(colorScheme == .dark ? .black : .white))
        .onDisappear {
            presentationMode.wrappedValue.dismiss()
        }
        .customNavigation()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    hideKeyboard()
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
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
        
        guard textIsAppropriate() else { return }
        
            ItemModel.priority = selectedPriority
            ItemModel.category = selectedCategory
            if let selectedDate = selectedDate {
                ItemModel.dueDate = selectedDate
                ItemModel.thereIsDate = true
            }
            
            ItemModel.save()
            presentationMode.wrappedValue.dismiss()
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
