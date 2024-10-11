//
//  Logger.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/7.
//

import Foundation

func debugLog(_ str: String) {
    #if DEBUG
    print("DEBUG: ", str)
    #endif
}
