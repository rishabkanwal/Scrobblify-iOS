//
//  Track.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/12/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import ObjectMapper

class Track: Mappable {
    
    var id: String?
    var name: String?
    var url: String?
    var playcount: String?
    var rank: String?
    var imageUrlString: String?
    var imageUrl: URL?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["mbid"]
        name <- map["name"]
        url <- map["url"]
        playcount <- map["playcount"]
        rank <- map["@attr.rank"]
        imageUrlString <- map["image.2.#text"]
        imageUrl = URL(string: imageUrlString!)
    }
    
}
