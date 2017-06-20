//
//  Track.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/17/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import ObjectMapper

class SearchTrack: Mappable {
    
    var name: String?
    var artist: String?
    var mbid: String?
    var imageUrlString: String?
    var imageUrl: URL?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["results.trackmatches.track.0.name"]
        artist <- map["results.trackmatches.track.0.artist"]
        mbid <- map["results.trackmatches.track.0.mbid"]
        imageUrlString <- map["results.trackmatches.track.0.image.3.#text"]
        imageUrl = URL(string: imageUrlString!)
    }
    
}
