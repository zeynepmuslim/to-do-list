import Foundation
import FirebaseFirestore
import FirebaseAuth

class ListViewModel: ObservableObject {
    @Published var items: [TaskModel] = [] // Görevleri tutan dizi
    @Published var showingNewTaskItem: Bool = false

    private let userId: String
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init(userId: String) {
        self.userId = userId
        fetchData()
    }
    
    // Firestore'dan veri çekme
    func fetchData() {
        listenerRegistration = db.collection("users").document(userId).collection("tasks")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                
                // Veriyi TaskModel'e dönüştür
                self.items = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: TaskModel.self)
                } ?? []
                
            }
    }

    // Görevi silme
    func delete(id: String) {
        db.collection("users")
            .document(userId)
            .collection("tasks")
            .document(id)
            .delete { error in
                if let error = error {
                    print("Error deleting document: \(error.localizedDescription)")
                }
            }
    }
    
    func getDueStatusPriority(for task: TaskModel) -> Int {
        guard let dueDate = task.dueDate else { return 4 } // No due date = Lowest priority
        let now = Date()
        let date = Date(timeIntervalSince1970: dueDate)
        let calendar = Calendar.current

        if date < now, !calendar.isDateInToday(date) {
            return 1 // Overdue
        } else if calendar.isDateInToday(date) {
            return 2 // Today
        } else if calendar.isDateInTomorrow(date) {
            return 3 // Tomorrow
        } else {
            return 4 // Future date
        }
    }

    deinit {
        listenerRegistration?.remove()
    }
}
