import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditView: View {
    
    @StateObject var viewModel = ListRowViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State var item: TaskModel
    @State var selectedPriority: String
    @State var selectedCategory: String
    @State var selectedDate: Date? = nil
    @State var showAlert: Bool = false
    @State var alertTitle: String = ""
    @State var showDateSheet: Bool = false
    @State var dateChanged: Bool = false
    
    @State var mytitle = ""
    @State var myThereIsDate = true
    @State var myDate = Date(timeIntervalSince1970: 0)
    
    let darkerSecond = Color("DarkerSecond")
    let myIcon = Image(systemName: "star.fill")
    
    private let characterLimit = 100
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack{
                    Text("task_title".localized())
                        .font(.headline)
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                }
                
                TextEditor(text: $mytitle)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .tint(Color("AccentColor"))
                    .autocorrectionDisabled(true)
                    .onChange(of: mytitle) { newValue in
                        if newValue.count > characterLimit {
                            mytitle = String(newValue.prefix(characterLimit))
                        }
                    }
                
                Text("\(mytitle.count)/\(characterLimit) " + "characters".localized())
                    .font(.footnote)
                    .foregroundColor( mytitle.count >= characterLimit ? .red : .secondary)
                
                HStack {
                    Text("priority".localized())
                        .font(.headline)
                    Spacer()
                    if selectedPriority == "Low" {
                        Group {
                            myIcon
                        }
                        .foregroundColor(.green)
                        .transition(.scale)
                        Text("😌")
                            .transition(.opacity)
                    } else if selectedPriority == "Medium" {
                        Group {
                            myIcon
                            myIcon
                        }
                        .transition(.scale)
                        .foregroundColor(.yellow)
                        Text("😬")
                            .transition(.opacity)
                    } else {
                        Group {
                            myIcon
                            myIcon
                            myIcon
                        }
                        .transition(.scale)
                        .foregroundColor(.red)
                        Text("🤯")
                            .transition(.opacity)
                    }
                }
                .padding(.top,10)
                .animation(.easeInOut, value: selectedPriority)
                
                Picker("priority".localized(), selection: $selectedPriority) {
                    ForEach(["Low", "Medium", "High"], id: \.self) { priority in
                        if priority == "Low" {
                            Text("low".localized())
                                .tag("Low")
                        } else if priority == "Medium" {
                            Text("medium".localized())
                                .tag("Medium")
                        } else {
                            Text("high".localized())
                                .tag("High")
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("category".localized())
                    .font(.headline)
                    .padding(.top,10)
                
                HStack(alignment: .center) {
                    CustomCategoryButton(title: "Other", action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedCategory = "other"
                        }
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
                
                if let dueDate = item.dueDate {
                    HStack {
                        Text("due_date".localized())
                            .font(.headline)
                        Text(viewModel.formattedDateLong(from: dueDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        if let dueDateStatus = viewModel.getDueDateStatus(from: dueDate) {
                            if !(dueDateStatus.text == "overdue".localized() && item.isCompleted) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(colorScheme == .dark ? .clear : Color(dueDateStatus.color.opacity(0.3)))
                                        .frame(height: 7)
                                    Text(dueDateStatus.text)
                                        .foregroundColor(colorScheme == .dark ? Color(dueDateStatus.color) : .black)
                                        .font(.caption)
                                        .bold()
                                        .lineLimit(1)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top,10)
                }
                
                Spacer()
                
                CustomButton(title: "save_changes".localized()) {
                    saveButtonPressed()
                }
                HStack{
                    Button {
                        presentationMode.wrappedValue.dismiss()
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
                    Button(action: {
                        withAnimation(.easeInOut) {
                            item.isCompleted.toggle()
                        }
                    }) {
                        Text(item.isCompleted ? "mark_not_completed".localized() : "mark_completed".localized())
                            .padding(.horizontal, 15)
                            .font(.headline)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(item.isCompleted ? Color.red : Color.green)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .transition(.scale)
                    }
                }
            }
            .padding()
        }
        .onDisappear {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear{
            loadData()
        }
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle))
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func loadData() {
        mytitle = item.title
    }
    func saveButtonPressed() {
        guard textIsAppropriate() else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        var itemCopy = item
        itemCopy.title = mytitle
        itemCopy.category = selectedCategory
        itemCopy.priority = selectedPriority
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("tasks")
            .document(item.id)
            .setData(itemCopy.asDictionary())
        presentationMode.wrappedValue.dismiss()
    }
    
    func triggerHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func textIsAppropriate() -> Bool {
        let trimmedText = mytitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty {
            alertTitle = "task_title_cannot_be_empty".localized()
            showAlert.toggle()
            triggerHapticFeedback(type: .error)
            return false
        }
        if trimmedText.count < 3 {
            alertTitle = "task_title_minimum_length".localized()
            showAlert.toggle()
            triggerHapticFeedback(type: .error)
            return false
        }
        triggerHapticFeedback(type: .success)
        return true
    }
}
