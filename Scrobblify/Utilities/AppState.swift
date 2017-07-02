//
//  AppState.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation

let requestsQueueName = "com.rishabkanwal.scrobblify.requestsQueue"

final class AppState {
    
    static let shared = AppState()
    
    let lastFmRequestManager = LastFmRequestManager()
    let scrobbleManager = ScrobbleManager()
    let requestsQueue = DispatchQueue(label: requestsQueueName)
    
    var lastFmSession: LastFmSession?
    
    var scrobblingEnabled = false
    var scrobblePercentage = 0.5
    
    fileprivate let defaults = UserDefaults.standard
    
    init() {
        retrieveScrobbleSettings(shouldSetup: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppState.settingsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    func saveSessionData() {
        defaults.set(lastFmSession?.key, forKey: "last_fm_session_key")
        defaults.set(lastFmSession?.username, forKey: "last_fm_username")
        defaults.set(String(describing: lastFmSession?.subscribers!), forKey: "last_fm_subscribers")
    }
    
    func retrieveSessionData() {
        lastFmSession = LastFmSession()
        if let key = defaults.string(forKey: "last_fm_session_key") {
            lastFmSession?.key = key
        }
        if let username = defaults.string(forKey: "last_fm_username") {
            lastFmSession?.username = username
        }
        if let subscribers = defaults.string(forKey: "last_fm_subscribers") {
            lastFmSession?.subscribers = Int(subscribers)
        }
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

private extension AppState {
    
    func retrieveScrobbleSettings(shouldSetup: Bool) {
        scrobblingEnabled = defaults.bool(forKey: "scrobbling_enabled")
        
        let uncheckedScrobblePercentage = defaults.double(forKey: "scrobble_percentage")
        
        scrobblePercentage = uncheckedScrobblePercentage == 0 ? scrobblePercentage : uncheckedScrobblePercentage
        if scrobblingEnabled {
            if shouldSetup {
                scrobbleManager.setupNewNowPlaying()
            }
            scrobbleManager.updateInBackground()
        } else {
            scrobbleManager.stopUpdateInBackground()
        }
    }
    
    @objc func settingsChanged() {
        retrieveScrobbleSettings(shouldSetup: true)
    }
    
}
