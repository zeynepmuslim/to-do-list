import Foundation
import FirebaseFirestore

class ListViewModel: ObservableObject {
    @Published var  showingNewTaskItem: Bool = false
    
    private let userId: String
    
    init(userId: String){
        self.userId = userId
    }
    
    func delete(id: String) {
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("tasks")
            .document(id)
            .delete()
    }
}
