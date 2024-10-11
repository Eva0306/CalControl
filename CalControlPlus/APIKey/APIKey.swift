//
//  APIKey.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/11.
//

import Foundation
import UniformTypeIdentifiers

enum APIKey {
    struct ApiKeyData: Decodable {
        let translationApiKey: String
        let nutritionApiKey: String
    }
    
    static var `default`: ApiKeyData = {
        guard let fileURL = Bundle.main.url(forResource: "APIKey", withExtension: UTType.propertyList.preferredFilenameExtension) else {
            fatalError("Couldn't find file APIKey.plist")
        }
        guard let data = try? Data(contentsOf: fileURL) else {
            fatalError("Couldn't read data from APIKey.plist")
        }
        guard let apiKeyData = try? PropertyListDecoder().decode(ApiKeyData.self, from: data) else {
            fatalError("Couldn't decode APIKey.plist")
        }
        return apiKeyData
    }()
}
