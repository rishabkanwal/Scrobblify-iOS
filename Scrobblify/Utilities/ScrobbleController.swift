//
//  ScrobbleController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/18/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import MediaPlayer

class ScrobbleController {
    
    let backgroundTask = BackgroundTask()
    let notificationCenter = NotificationCenter.default
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    let musicPlayerController = MPMusicPlayerController()
    
    var currentNowPlaying: MPMediaItem?
    
    init() {
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    private func getNowPlaying() -> MPMediaItem?{
        let nowPlaying = musicPlayer.nowPlayingItem
        if (nowPlaying?.mediaType == MPMediaType.music && nowPlaying?.title != nil) {
            return nowPlaying
        }
        return nil
    }
    
    private func getMbid(track: MPMediaItem, completionHandler: @escaping (String?) -> ()) {
        
        AppState.shared.lastFmRequest.searchTrack(track: track.title!, artist: track.artist!, completionHandler: {
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
    
    
    private func setNowPlaying(nowPlaying: MPMediaItem?, completionHandler: ((String?) -> Void)? = nil) {
        if (nowPlaying != nil) {
            getMbid(track: nowPlaying!, completionHandler: {
                mbid in
                if(mbid != nil) {
                    AppState.shared.lastFmRequest.updateNowPlaying(track: nowPlaying!.title!, artist: nowPlaying!.artist!, album: nowPlaying!.albumTitle!, albumArtist: nowPlaying!.albumArtist!, mbid: mbid!, timestamp: Int(Date().timeIntervalSince1970), completionHandler: {
                        responseJsonString, error in
                        if (error == nil && completionHandler != nil) {
                            completionHandler!(mbid!)
                        } else if (completionHandler != nil) {
                            completionHandler!(nil)
                        }
                    })
                }
            })
        }
    }
    
    private func scrobble(nowPlaying: MPMediaItem?, mbid: String) {
        AppState.shared.lastFmRequest.scrobbleTrack(track: nowPlaying!.title!, artist: nowPlaying!.artist!, album: nowPlaying!.albumTitle!, albumArtist: nowPlaying!.albumArtist!, mbid: mbid, timestamp: Int(Date().timeIntervalSince1970), completionHandler: {
            responseJsonString, error in
            if(error == nil) {
                print("Scrobble posted")
            } else {
                print(error!)
            }
        })
    }
    
    
    @objc func update() {
        let nowPlaying = getNowPlaying()
        if (musicPlayerController.playbackState == MPMusicPlaybackState.playing && self.currentNowPlaying != nowPlaying) {
            self.currentNowPlaying = nowPlaying
            setNowPlaying(nowPlaying: nowPlaying, completionHandler: {
                mbid in
                if (mbid != nil) {
                    let scrobbleInterval = nowPlaying!.playbackDuration / 2
                    DispatchQueue.main.asyncAfter(deadline: .now() + scrobbleInterval, execute: {
                        let newNowPlaying = self.getNowPlaying()
                        if (newNowPlaying == nowPlaying) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + scrobbleInterval, execute: {
                                self.scrobble(nowPlaying: nowPlaying!, mbid: mbid!)
                                self.currentNowPlaying = nil
                            })
                        }
                    })
                }
            })
        }
    }
    
    func updateInBackground() {
        backgroundTask.startBackgroundTask()
        notificationCenter.addObserver(self, selector: #selector(self.update), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        notificationCenter.addObserver(self, selector: #selector(self.update), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
    }
    
}
