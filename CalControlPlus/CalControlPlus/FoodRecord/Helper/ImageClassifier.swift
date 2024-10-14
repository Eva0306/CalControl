//
//  ImageClassifier.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/14.
//

import Vision
import UIKit

class ImageClassifier {
    
    // MARK: - Image Classification
    func classify(image: UIImage, completion: @escaping (String?, Float?) -> Void) {
        let configuration = MLModelConfiguration()
        
        guard let model = try? FoodImageClassifier(configuration: configuration).model,
              let visionModel = try? VNCoreMLModel(for: model) else {
            print("Failed to load model")
            completion(nil, nil)
            return
        }
        
        let request = VNCoreMLRequest(model: visionModel) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                  let firstResult = results.first else {
                print("Couldn't classify the image")
                completion(nil, nil)
                return
            }
            
            let confidence = firstResult.confidence * 100
            completion(firstResult.identifier, confidence)
        }
        
        guard let ciImage = CIImage(image: image) else {
            print("Couldn't transform UIImage to CIImage")
            completion(nil, nil)
            return
        }
        
#if targetEnvironment(simulator)
        request.usesCPUOnly = true
#endif
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print("Vision request failed with error - \(error)")
                completion(nil, nil)
            }
        }
    }
}
