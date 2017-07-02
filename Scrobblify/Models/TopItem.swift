//
//  TopItem.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/12/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import ObjectMapper

class TopItem {
    
    var mbid: String?
    var name: String?
    var playcount: String?
    var rank: String?
    var imageUrlString: String?
    var imageUrl: URL?
    
    required init?(map: Map) {}
    
}

extension TopItem: Mappable {
    
    func mapping(map: Map) {
        mbid <- map["mbid"]
        name <- map["name"]
        playcount <- map["playcount"]
        rank <- map["@attr.rank"]
        imageUrlString <- map["image.2.#text"]
        imageUrl = URL(string: imageUrlString!)
    }
    
}
