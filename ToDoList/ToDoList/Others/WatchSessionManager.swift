//
//  WatchSessionManager.swift
//  ToDoList
//
//  Created by Zeynep Müslim on 20.12.2024.

import WatchConnectivity
import Foundation

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager() // Singleton kullanım

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendTasksToWatch(tasks: [TaskModel]) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(tasks) {
            let message: [String: Any] = ["tasks": data]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending tasks to watch: \(error.localizedDescription)")
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

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {}
}
