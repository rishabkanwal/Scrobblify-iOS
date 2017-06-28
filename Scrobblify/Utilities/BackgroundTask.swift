//
//  BackgroundTask.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/19/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit
import AVFoundation

class BackgroundTask {
    
    var player = AVAudioPlayer()
    var timer = Timer()
    var backgroundTaskRunning = false
    
    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioInterupted), name: NSNotification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        self.playAudio()
        backgroundTaskRunning = true
    }
    
    func stop() {
        if (backgroundTaskRunning) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
            player.stop()
        }
    }
    
    @objc fileprivate func audioInterupted(_ notification: Notification) {
        if notification.name == NSNotification.Name.AVAudioSessionInterruption && notification.userInfo != nil {
            var info = notification.userInfo!
            var intValue = 0
            (info[AVAudioSessionInterruptionTypeKey]! as AnyObject).getValue(&intValue)
            if intValue == 1 {
                playAudio()
            }
        }
    }
    
    fileprivate func playAudio() {
        do {
            let blankAudio = NSDataAsset(name:"Blank")!
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with:AVAudioSessionCategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try self.player = AVAudioPlayer(data: blankAudio.data, fileTypeHint: "wav")
            self.player.numberOfLoops = -1
            self.player.volume = 0.01
            self.player.prepareToPlay()
            self.player.play()
        } catch {
            print(error)
        }
    }
    
}
