//
//  WatchSessionManagerW.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 20.12.2024.
//

import WatchConnectivity
import Foundation

class WatchSessionManagerW: NSObject, ObservableObject, WCSessionDelegate {
    @Published var tasks: [TaskModel] = []

    static let shared = WatchSessionManagerW() // Singleton kullanım

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let data = message["tasks"] as? Data {
            let decoder = JSONDecoder()
            if let receivedTasks = try? decoder.decode([TaskModel].self, from: data) {
                DispatchQueue.main.async {
                    self.tasks = receivedTasks
                }
            }
        }
    }

    // WCSessionDelegate Zorunlu Fonksiyonlar
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

//    func sessionDidBecomeInactive(_ session: WCSession) {}
//
//    func sessionDidDeactivate(_ session: WCSession) {}
}
