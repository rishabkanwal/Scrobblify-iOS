//
//  AppState.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation

final class AppState {
    
    static let shared = AppState()
    let defaults: UserDefaults
    let requestManager = RequestManager()
    let scrobbleManager = ScrobbleManager()
    var session: Session?
    var requestsQueue: DispatchQueue
    
    init() {
        defaults = UserDefaults.standard
        requestsQueue = DispatchQueue(label: "requests")
    }
    
    func saveSessionData() {
        self.defaults.set(session!.key, forKey: "sessionKey")
        self.defaults.set(session!.username, forKey: "username")
        self.defaults.set(String(session!.subscribers!), forKey: "subscribers")
    }
    
    func retrieveSessionData() {
        session = Session()
        if let key = defaults.string(forKey: "sessionKey") {
            session!.key = key
        }
        if let username = defaults.string(forKey: "username") {
            session!.username = username
        }
        if let subscribers = defaults.string(forKey: "subscribers") {
            session!.subscribers = Int(subscribers)
        }
    }
    
}
