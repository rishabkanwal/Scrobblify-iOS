//
//  User.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import ObjectMapper

class LastFmSession: Mappable {
    
    var key: String?
    var username: String?
    var subscribers: Int?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        key <- map["session.key"]
        username <- map["session.name"]
        subscribers <- map["session.subscriber"]
    }
    
}
