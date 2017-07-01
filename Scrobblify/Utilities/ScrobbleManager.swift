//
//  ScrobbleController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/18/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import MediaPlayer


class ScrobbleManager {
    
    struct NowPlaying {
        var media: MPMediaItem?
        var mbid: String?
        var timePlayed: TimeInterval?
        var timeLastStarted: Date?
        var isLastFmNowPlaying: Bool
    }
    
    let backgroundTask = BackgroundTask()
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    let musicPlayerController = MPMusicPlayerController()
    
    var currentNowPlaying: NowPlaying? = nil
    
    init() {
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    private func getNowPlaying() -> MPMediaItem?{
        let nowPlayingMedia = musicPlayer.nowPlayingItem
        if (nowPlayingMedia?.mediaType == MPMediaType.music && nowPlayingMedia?.title != nil) {
            return nowPlayingMedia
        }
        return nil
    }
    
    
    private func getMbid(track: MPMediaItem, completionHandler: @escaping (String?) -> ()) {
        AppState.shared.lastFmRequestManager.searchTrack(track: track.title!, artist: track.artist!, completionHandler: {
            responseJsonString, error in
            if (!(error != nil)) {
                let searchTrack = SearchTrack(JSONString: responseJsonString!)
                if (searchTrack?.mbid != nil) {
                    completionHandler(searchTrack?.mbid)
                }
            } else {
                completionHandler(nil)
            }
        })
    }
    
    private func setNowPlaying() {
        AppState.shared.lastFmRequestManager.updateNowPlayingTrack(track: currentNowPlaying!.media!.title!, artist: currentNowPlaying!.media!.artist!, album: currentNowPlaying!.media!.albumTitle!, albumArtist: currentNowPlaying!.media!.albumArtist!, mbid: currentNowPlaying!.mbid!, timestamp: Int(Date().timeIntervalSince1970), completionHandler: {
            responseJsonString, error in
            if (error == nil) {
                self.currentNowPlaying?.isLastFmNowPlaying = true
                print("Set now playing")
            } else {
                print(error!)
            }
        })
    }
    
    private func scrobbleIfThresholdReached() {
        let scrobblePercentage = AppState.shared.scrobblePercentage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if (self.currentNowPlaying!.timePlayed! >= self.currentNowPlaying!.media!.playbackDuration * scrobblePercentage) {
                AppState.shared.lastFmRequestManager.scrobbleTrack(track: self.currentNowPlaying!.media!.title!, artist: self.currentNowPlaying!.media!.artist!, album: self.currentNowPlaying!.media!.albumTitle!, albumArtist: self.currentNowPlaying!.media!.albumArtist!, mbid: self.currentNowPlaying!.mbid!, timestamp: Int(Date().timeIntervalSince1970), completionHandler: {
                    responseJsonString, error in
                    if(error == nil) {
                        self.currentNowPlaying = nil
                        print("Scrobble posted")
                    } else {
                        print(error!)
                    }
                })
            }
        })
        
    }
    
    func setupNewNowPlaying() {
        let newNowPlayingMedia = getNowPlaying()
        if (newNowPlayingMedia != nil) {
            getMbid(track: newNowPlayingMedia!, completionHandler: {
                mbid in
                if (mbid != nil) {
                    self.currentNowPlaying = NowPlaying(media:newNowPlayingMedia!, mbid: mbid, timePlayed: 0, timeLastStarted: nil, isLastFmNowPlaying: false)
                    if (self.musicPlayerController.playbackState == MPMusicPlaybackState.playing) {
                        self.currentNowPlaying!.timeLastStarted = Date()
                        self.setNowPlaying()
                    }
                }
            })
        }
    }
    
    @objc func nowPlayingPlaybackStateChanged() {
        if (currentNowPlaying?.timeLastStarted != nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                
                if (self.musicPlayerController.playbackState == MPMusicPlaybackState.playing) {
                    if (!self.currentNowPlaying!.isLastFmNowPlaying) {
                        self.setNowPlaying()
                    }
                } else if (self.musicPlayerController.playbackState == MPMusicPlaybackState.paused || self.musicPlayerController.playbackState == MPMusicPlaybackState.interrupted || self.musicPlayerController.playbackState == MPMusicPlaybackState.stopped) {
                    self.currentNowPlaying!.timePlayed! += Date().timeIntervalSince(self.currentNowPlaying!.timeLastStarted!)
                    self.scrobbleIfThresholdReached()
                }
            })
        } else {
            setupNewNowPlaying()
        }
    }
    
    @objc func nowPlayingItemChanged() {
        if(currentNowPlaying?.timeLastStarted != nil) {
            if (currentNowPlaying!.timeLastStarted != nil) {
                currentNowPlaying!.timePlayed! += Date().timeIntervalSince(currentNowPlaying!.timeLastStarted!)
                scrobbleIfThresholdReached()
            }
        }
        setupNewNowPlaying()
    }
    
    func updateInBackground() {
        let notificationCenter = NotificationCenter.default
        backgroundTask.start()
        notificationCenter.addObserver(self, selector: #selector(self.nowPlayingPlaybackStateChanged), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
        notificationCenter.addObserver(self, selector: #selector(self.nowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
    }
    
    func stopUpdateInBackground() {
        backgroundTask.stop()
    }
    
}
