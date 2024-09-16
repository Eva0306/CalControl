//
//  TranslationManager.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/16.
//

import Foundation

class TranslationManager: NSObject {

    static let shared = TranslationManager()

    private let apiKey = "AIzaSyB7wa28UbtunfsZPiXE6LqAIUN9BxrtwRc"
    
    var sourceLanguageCode: String?

    override init() {
        super.init()
    }
    
    func detectAndTranslateText(_ text: String, completion: @escaping (_ translatedText: String?) -> Void) {
        // Step 1: Detect the language of the text
        detectLanguage(forText: text) { detectedLanguage in
            guard let detectedLanguage = detectedLanguage else {
                completion(nil)
                return
            }
            // Step 2: If detected language is English, return the original text
            if detectedLanguage == "en" {
                completion(text)
            } else {
                // Step 3: Translate the text after detecting the language
                self.translateText(text, from: detectedLanguage, to: "en", completion: completion)
            }
        }
    }

    private func detectLanguage(forText text: String, completion: @escaping (_ language: String?) -> Void) {
        let urlParams = ["key": apiKey, "q": text]

        makeRequest(usingTranslationAPI: .detectLanguage, urlParams: urlParams) { (results) in
            guard let results = results else { completion(nil); return }

            if let data = results["data"] as? [String: Any], let detections = data["detections"] as? [[[String: Any]]] {
                var detectedLanguages = [String]()

                for detection in detections {
                    for currentDetection in detection {
                        if let language = currentDetection["language"] as? String {
                            detectedLanguages.append(language)
                        }
                    }
                }

                if detectedLanguages.count > 0 {
                    self.sourceLanguageCode = detectedLanguages[0]
                    completion(detectedLanguages[0])
                } else {
                    completion(nil)
                }

            } else {
                completion(nil)
            }
        }
    }

    private func translateText(_ text: String, from sourceLang: String, to targetLang: String, completion: @escaping (_ translatedText: String?) -> Void) {
        let urlParams = ["key": apiKey, "q": text, "target": targetLang, "source": sourceLang]

        makeRequest(usingTranslationAPI: .translate, urlParams: urlParams) { (results) in
            guard let results = results else { completion(nil); return }

            if let data = results["data"] as? [String: Any],
               let translations = data["translations"] as? [[String: Any]],
               let translatedText = translations.first?["translatedText"] as? String {
                completion(translatedText)
            } else {
                completion(nil)
            }
        }
    }

    
    private func makeRequest(usingTranslationAPI api: TranslationAPI, urlParams: [String: String], completion: @escaping (_ results: [String: Any]?) -> Void) {
        
        if var components = URLComponents(string: api.getURL()) {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in urlParams {
                components.queryItems?.append(URLQueryItem(name: key, value: value))
            }
            
            if let url = components.url {
                var request = URLRequest(url: url)
                request.httpMethod = api.getHTTPMethod()
                
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: request) { (results, response, error) in
                    
                    if let error = error {
                        print(error)
                        completion(nil)
                        
                    } else {
                        if let response = response as? HTTPURLResponse, let results = results {
                            if response.statusCode == 200 || response.statusCode == 201 {
                                do {
                                    if let resultsDict = try JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: Any] {
                                        completion(resultsDict)
                                    }
                                } catch {
                                    print("Error: ", error.localizedDescription)
                                }
                            } else {
                                print("Status Code from TranslationManager: ", response.statusCode)
                            }
                        } else {
                            completion(nil)
                        }
                    }
                }
                task.resume()
            }
        }
    }
}
