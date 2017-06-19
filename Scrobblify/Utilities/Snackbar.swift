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
    DispatchQueue.main.async(execute: {
        let snackbar = TTGSnackbar.init(message: "  " + message, duration: .middle)
        snackbar.backgroundColor = UIColor.darkGray
        snackbar.show()
    })
}
