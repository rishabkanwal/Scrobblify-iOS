//
//  RecentTrack.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import ObjectMapper

class RecentTrack: Mappable {
    
    var name: String?
    var id: String?
    var url: String?
    var artist: String?
    var artistId: String?
    var album: String?
    var albumId: String?
    var imageUrlString: String?
    var nowPlaying: String?
    var unixTimestamp: String?
    var timestamp: Date?
    var imageUrl: URL?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["mbid"]
        url <- map["url"]
        artist <- map["artist.#text"]
        artistId <- map["artist.mbid"]
        album <- map["album.#text"]
        albumId <- map["album.mbid"]
        imageUrlString <- map["image.2.#text"]
        nowPlaying <- map["@attr.nowplaying"]
        unixTimestamp <- map["date.uts"]
        imageUrl = URL(string: imageUrlString!)
        if !(nowPlaying != nil) {
            timestamp = Date(timeIntervalSince1970: Double(unixTimestamp!)!)
        }
    }
    
    func getFormattedTimestamp() -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.timeSince(from: timestamp! as NSDate)
        
    }
    
}
