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

class LastFmRequest{
    let baseUrl = configuration().baseUrl
    let apiKey = configuration().apiKey
    let sharedSecret = configuration().sharedSecret

    
    func getApiSignature(username: String, password: String, method: String) -> String {
            return "api_key\(apiKey)method\(method)password\(password)username\(username)\(sharedSecret)".md5()
    }
    
    func makeApiCall (method: HTTPMethod, parameters: Parameters, completionHandler: @escaping (String?, Error?) -> ()) {
        Alamofire.request(baseUrl, method: .post, parameters: parameters).validate().responseString { response in
            switch response.result {
            case .success(let value):
                print(value)
                completionHandler(value, nil)
            case .failure(let error):
                print(error)
                completionHandler(nil, error)
            }
        }

    }
    
    func getSession(username: String, password: String, completionHandler: @escaping (String?, Error?) -> ()) {
        let apiMethod = "auth.getMobileSession"
        let parameters: Parameters = ["format": "json",
                                      "method": apiMethod,
                                      "api_key": apiKey,
                                      "api_sig": getApiSignature(username: username, password: password, method: apiMethod),
                                      "username": username,
                                      "password": password
                                       ]
        makeApiCall(method: .post, parameters: parameters, completionHandler: completionHandler)
        
    }
    
    func getUserInfo(completionHandler: @escaping (String?, Error?) -> ()) {
        let parameters: Parameters = ["format": "json",
                                      "method": "user.getInfo",
                                      "api_key": apiKey,
                                      "user": AppState.shared.session!.username!,
                                      "password": "password"
                                      ]
        makeApiCall(method: .get, parameters: parameters, completionHandler: completionHandler)
        
    }
    
    func getRecentTracks(page: Int, completionHandler: @escaping (String?, Error?) -> ()) {
        let parameters: Parameters = ["format": "json",
                                      "method": "user.getRecentTracks",
                                      "api_key": apiKey,
                                      "user": AppState.shared.session!.username!,
                                      "password": "password",
                                      "limit": 200,
                                      "page": page
                                      ]
        makeApiCall(method: .get, parameters: parameters, completionHandler: completionHandler)
        
    }
    
    func getTopItem(requestType: String, page: Int, timePeriod: String, completionHandler: @escaping (String?, Error?) -> ()) {
        
        let parameters: Parameters = ["format": "json",
                                      "method": requestType,
                                      "api_key": apiKey,
                                      "user": AppState.shared.session!.username!,
                                      "password": "password",
                                      "limit": 200,
                                      "page": page,
                                      "period": timePeriod
        ]
        makeApiCall(method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    func getTopArtists(page: Int, timePeriod: String, completionHandler: @escaping (String?, Error?) -> ()) {
        getTopItem(requestType: "user.getTopArtists", page: page, timePeriod: timePeriod, completionHandler: completionHandler)
    }
    
    func getTopAlbums(page: Int, timePeriod: String, completionHandler: @escaping (String?, Error?) -> ()) {
        getTopItem(requestType: "user.getTopAlbums", page: page, timePeriod: timePeriod, completionHandler: completionHandler)
    }
    
    func getTopTracks(page: Int, timePeriod: String, completionHandler: @escaping (String?, Error?) -> ()) {
        getTopItem(requestType: "user.getTopTracks", page: page, timePeriod: timePeriod, completionHandler: completionHandler)

    }
    


    
}
