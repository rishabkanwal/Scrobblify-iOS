//
//  User.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var username: String?
    var image: String?
    var url: String?
    var country: String?
    var age: String?
    var gender: String?
    var subscribers: String?
    var playcount: String?
    var playlists: String?
    var registeredDate: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        username <- map["user.name"]
        image <- map["user.image.3.#text"]
        url <- map["user.url"]
        country <- map["user.country"]
        age <- map["user.age"]
        gender <- map["user.gender"]
        subscribers <- map["user.subscriber"]
        playcount <- map["user.playcount"]
        playlists <- map["user.playlists"]
        registeredDate <- map["user.registered.#text"]
    }
    
}
