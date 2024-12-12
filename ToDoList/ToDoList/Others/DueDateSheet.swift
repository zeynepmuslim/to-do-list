import SwiftUI

struct DueDateSheet: View {
    @Binding var selectedDate: Date?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select a Due Date", selection: Binding(
                    get: { selectedDate ?? Date() },
                    set: { selectedDate = $0 }
                ), displayedComponents: [.date])
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                
                Button("Save") {
                    dismiss()
                }
                .padding()
                .background(Capsule().fill(Color.blue))
                .foregroundColor(.white)
            }
            .navigationTitle("Set Due Date")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
