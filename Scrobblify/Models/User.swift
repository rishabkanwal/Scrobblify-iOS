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
    var imageUrlString: String?
    var imageUrl: URL?
    var country: String?
    var age: String?
    var gender: String?
    var subscribers: String?
    var playcount: String?
    var playlistCount: String?
    var registeredDate: Double?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        username <- map["user.name"]
        country <- map["user.country"]
        age <- map["user.age"]
        gender <- map["user.gender"]
        subscribers <- map["user.subscriber"]
        playcount <- map["user.playcount"]
        playlistCount <- map["user.playlists"]
        registeredDate <- map["user.registered.#text"]
        imageUrlString <- map["user.image.3.#text"]
        imageUrl = URL(string: imageUrlString!)
    }
    
    func getFormattedPlaycount() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: Int(playcount!)! as NSNumber)!
    }
    
    func getFormattedRegisterDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: registeredDate!))
    }
    
}
