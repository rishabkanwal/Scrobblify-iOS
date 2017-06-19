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
    
    private func getNowPlaying() -> MPMediaItem?{
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem
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

    func setNowPlaying(completionHandler: ((Bool) -> Void)? = nil) {
        let nowPlaying = getNowPlaying()
        if (nowPlaying != nil) {
            getMbid(track: nowPlaying!, completionHandler: {
                mbid in
                if(mbid != nil) {
                    AppState.shared.lastFmRequest.updateNowPlaying(track: nowPlaying!.title!, artist: nowPlaying!.artist!, album: nowPlaying!.albumTitle!, albumArtist: nowPlaying!.albumArtist!, mbid: mbid!, timestamp: Int(Date().timeIntervalSince1970), completionHandler: {
                        responseJsonString, error in
                        if (error == nil && completionHandler != nil) {
                            completionHandler!(true)
                        } else if (completionHandler != nil) {
                            completionHandler!(false)
                        }
                    })
                }
            })
        }
    }
    
    func scrobble(completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        let nowPlaying = getNowPlaying()
        if (nowPlaying != nil) {
            getMbid(track: nowPlaying!, completionHandler: {
                mbid in
                if(mbid != nil) {
                    AppState.shared.lastFmRequest.scrobbleTrack(track: nowPlaying!.title!, artist: nowPlaying!.artist!, album: nowPlaying!.albumTitle!, albumArtist: nowPlaying!.albumArtist!, mbid: mbid!, timestamp: Int(Date().timeIntervalSince1970), completionHandler: {
                        responseJsonString, error in
                        if (error != nil && completionHandler != nil) {
                            completionHandler!(UIBackgroundFetchResult.newData)
                        } else if (completionHandler != nil) {
                            completionHandler!(UIBackgroundFetchResult.failed)
                        }
                    })
                }
            })
        }
    }
    
}
