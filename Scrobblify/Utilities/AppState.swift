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
    let defaults = UserDefaults.standard
    let lastFmRequestManager = LastFmRequestManager()
    let scrobbleManager = ScrobbleManager()
    
    var session: Session?
    var requestsQueue: DispatchQueue
    
    var scrobblingEnabled = false
    var scrobblePercentage = 0.5
    
    init() {
        requestsQueue = DispatchQueue(label: "requests")
        retrieveScrobbleSettings(shouldSetup: false)
        NotificationCenter.default.addObserver(self, selector: #selector(AppState.settingsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    private func retrieveScrobbleSettings(shouldSetup: Bool) {
        scrobblingEnabled = defaults.bool(forKey: "scrobbling_enabled")
        let uncheckedScrobblePercentage = defaults.double(forKey: "scrobble_percentage")
        scrobblePercentage = uncheckedScrobblePercentage == 0 ? scrobblePercentage : uncheckedScrobblePercentage
        if (scrobblingEnabled) {
            if(shouldSetup) {
                scrobbleManager.setupNewNowPlaying()
            }
            scrobbleManager.updateInBackground()
        } else {
            scrobbleManager.stopUpdateInBackground()
        }
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
    
    @objc private func settingsChanged() {
        retrieveScrobbleSettings(shouldSetup: true)
    }
    
    func enableScrobbling() {
        defaults.set(true, forKey: "scrobbling_enabled")
        retrieveScrobbleSettings(shouldSetup: true)
    }
    
    func disableScrobbling() {
        defaults.set(false, forKey: "scrobbling_enabled")
    }
    
    func shouldShowEnableScrobblingDialog() -> Bool {
        return !(defaults.bool(forKey: "disable_enable_scrobbling_dialog"))
    }
    
    func disableEnableScrobblingDialog() {
        defaults.set(true, forKey: "disable_enable_scrobbling_dialog")
    }
    
}
