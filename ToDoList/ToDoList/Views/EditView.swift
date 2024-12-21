import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditView: View {
    
    
    @StateObject var viewModel = ListRowViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    @State var item: TaskModel // Düzenlenecek öğe
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
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 10) {
                    Button{
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left.2")
                            .foregroundColor(.accentColor)
                            .font(.headline)
                    }
                    HStack{
                        Text("Task Title")
                            .font(.headline)
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    }
                }
                    
                TextEditor(text: $mytitle)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .tint(Color("AccentColor"))
                    .autocorrectionDisabled(true)
                    
                Text("\(item.title.count)/\(characterLimit) characters")
                                    .font(.footnote)
                                    .foregroundColor( mytitle.count >= characterLimit ? .red : .secondary)

                HStack {
                    Text("Task Priority")
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
                .animation(.easeInOut, value: selectedPriority)
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
                
                Spacer()

                // Save Button
                CustomButton(title: "Save Changes") {
                    saveButtonPressed()
                }
                HStack{
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
                    Button(action: {
                        withAnimation(.easeInOut) {
                            item.isCompleted.toggle()
                        }
                    }) {
                        Text(item.isCompleted ? "Mark Not Completed 😔" : "Mark Completed 🥳")
                            .padding(.horizontal, 15)
                            .font(.headline)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(item.isCompleted ? Color.red : Color.green)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            
                        //                            .transition(.opacity)
                            .transition(.scale)
                    }
                }
                
            }
            .padding()
        }
        .onAppear{
            loadData()
           
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle))
        }
    }

    func loadData() {
        mytitle = item.title
        print(mytitle)
        print("hi guys")
    }
    func saveButtonPressed() {
            guard textIsAppropriate() else { return } // Ensure validation passes
            
        
            
            // Firestore reference
            
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
        
            print("save button pressed")
            presentationMode.wrappedValue.dismiss()
    }


    func triggerHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func textIsAppropriate() -> Bool {
        let trimmedText = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
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
        
        if trimmedText.count >= characterLimit {
            alertTitle = "Task title cannot exceed \(characterLimit) characters!"
            showAlert.toggle()
            triggerHapticFeedback(type: .error)
            return false
        }
        triggerHapticFeedback(type: .success)
        return true
    }
}
