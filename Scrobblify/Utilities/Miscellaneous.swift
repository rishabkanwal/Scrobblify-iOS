//
//  Snackbar.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/19/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import Foundation
import TTGSnackbar

func makeSnackbar(message: String) {
    let snackbar = TTGSnackbar.init(message: "  " + message, duration: .middle)
    snackbar.backgroundColor = UIColor.darkGray

    DispatchQueue.main.async(execute: {
        snackbar.show()
    })
}

func openSettings() {
    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
        return
    }
    
    if UIApplication.shared.canOpenURL(settingsUrl) {
        UIApplication.shared.open(settingsUrl)
    }
}
