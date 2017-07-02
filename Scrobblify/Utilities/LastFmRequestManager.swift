//
//  LastfmRequest.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift

class LastFmRequestManager{
    
    fileprivate let baseUrl = configuration().lastFmBaseUrl
    fileprivate let apiKey = configuration().apiKey
    fileprivate let sharedSecret = configuration().sharedSecret
    fileprivate let baseParameters: Parameters = ["api_key": configuration().apiKey]
    
    func getSession(username: String, password: String, completionHandler: @escaping (String?, Error?) -> ()) {
        var parameters = baseParameters
        parameters["method"] = "auth.getMobileSession"
        parameters["username"] = username
        parameters["password"] = password
        parameters["api_sig"] = getApiSignature(parameters: parameters)
        
        makeApiCall(method: .post, parameters: parameters, completionHandler: completionHandler)
    }
    
    func getUserInfo(completionHandler: @escaping (String?, Error?) -> ()) {
        var parameters = baseParameters
        parameters["method"] = "user.getInfo"
        parameters["user"] = AppState.shared.lastFmSession?.username
        
        makeApiCall(method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    func getRecentTracks(page: Int, completionHandler: @escaping (String?, Error?) -> ()) {
        var parameters = baseParameters
        parameters["method"] = "user.getRecentTracks"
        parameters["user"] = AppState.shared.lastFmSession?.username
        parameters["limit"] = 200
        parameters["page"] = page
        
        makeApiCall(method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    func getTopItems(apiMethod: String, page: Int, timePeriod: String, completionHandler: @escaping (String?, Error?) -> ()) {
        var parameters = baseParameters
        parameters["method"] = apiMethod
        parameters["user"] = AppState.shared.lastFmSession?.username
        parameters["limit"] = 200
        parameters["page"] = page
        parameters["period"] = timePeriod

        
        makeApiCall(method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    func searchTrack(track:String, artist:String, completionHandler: @escaping (String?, Error?) -> ()) {
        var parameters = baseParameters
        parameters["method"] = "track.search"
        parameters["track"] = track
        parameters["artist"] = artist
        parameters["limit"] = 1
        
        makeApiCall(method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    func scrobbleTrack(track: String, artist: String, album: String, albumArtist: String, mbid: String, timestamp: Int, completionHandler: @escaping (String?, Error?) -> ()) {
        postTrack(method: "track.scrobble", track: track, artist: artist, album: album, albumArtist: albumArtist, mbid: mbid, timestamp: timestamp, completionHandler: completionHandler)
    }
    
    func updateNowPlayingTrack(track: String, artist: String, album: String, albumArtist: String, mbid: String, timestamp: Int, completionHandler: @escaping (String?, Error?) -> ()) {
        postTrack(method: "track.updateNowPlaying", track: track, artist: artist, album: album, albumArtist: albumArtist, mbid: mbid, timestamp: timestamp, completionHandler: completionHandler)
    }
    
}

private extension LastFmRequestManager {
    
    func getApiSignature(parameters: Parameters) -> String {
        var apiParams = ""
        for (parameter, value) in parameters.sorted(by: { $0.0 < $1.0 }) {
            apiParams.append("\(parameter)\(value)")
        }
        return "\(apiParams)\(sharedSecret)".md5()
    }
    
    func makeApiCall (method: HTTPMethod, parameters: Parameters, completionHandler: @escaping (String?, Error?) -> ()) {
        var finalParameters = parameters
        finalParameters["format"] = "json"
        Alamofire.request(baseUrl, method: .post, parameters: finalParameters).validate().responseString { response in
            switch response.result {
            case .success(let value):
                //print(value)
                completionHandler(value, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func postTrack(method: String, track: String, artist: String, album: String, albumArtist: String, mbid: String, timestamp: Int, completionHandler: @escaping (String?, Error?) -> ()) {
        var parameters = baseParameters
        parameters["method"] = method
        parameters["sk"] = AppState.shared.lastFmSession?.key
        parameters["track"] = track
        parameters["artist"] = artist
        parameters["album"] = album
        parameters["albumArtist"] = albumArtist
        parameters["mbid"] = mbid
        parameters["timestamp"] = String(timestamp)
        parameters["api_sig"] = getApiSignature(parameters: parameters)
        
        makeApiCall(method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
}
