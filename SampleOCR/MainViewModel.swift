//
//  MainViewModel.swift
//  SampleOCR
//
//  Created by NotSmall on 23/3/2564 BE.
//

import UIKit
import Vision
import VisionKit
import MLKit

protocol MainViewModelDelegate {
    func setImage(image: UIImage)
    func setResultText(text: String)
}

class MainViewModel {
    var displayImage:UIImage! = nil {
        didSet {
            delegate.setImage(image: displayImage)
//            processImage(image: displayImage)
            processImageMLKit(image: displayImage)
        }
    }
    
    var resultText:String! = nil {
        didSet {
            DispatchQueue.main.async {
                self.delegate.setResultText(text: self.resultText)
            }
            
        }
    }
    
    var delegate:MainViewModelDelegate! = nil
    
    //MARK: Vision
    private func processImage(image:UIImage) {
        guard let cgImage = image.cgImage else {
            resultText = "Invalid Text"
            return
        }
        
        let request = VNRecognizeTextRequest { (request , error) in
            if let error = error {
                self.resultText = "Error Detecting text"
            } else {
                self.handleDetectionResults(results: request.results)
            }
        }
        
        request.recognitionLanguages = ["en_US","th_TH"]
        request.recognitionLevel = .accurate
        
        performDetection(request: request, image: cgImage)
    }
    
    private func performDetection(request: VNRecognizeTextRequest, image: CGImage) {
        let requests = [request]
        let handle = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handle.perform(requests)
            } catch let error {
                self.resultText = error.localizedDescription
            }
        }
    }
    
    private func handleDetectionResults(results:[Any]?) {
        guard let results = results, results.count > 0 else {
            self.resultText = "No text found"
            return
        }
        
        var mutText = ""
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    
                    print(text.string)
                    print(text.confidence)
                    print(observation.boundingBox)
                    print("\n")
                    
                    if text.confidence > 0.3 {
                        mutText = mutText + text.string + "\n"
                    }
                    
                }
            }
        }
        
        resultText = mutText
    }
    
    //MARK: MLKit
    private func processImageMLKit(image:UIImage) {
        let vImage = VisionImage(image: image)
        vImage.orientation = image.imageOrientation
        let textRecognizer = TextRecognizer.textRecognizer()
        textRecognizer.process(vImage) { (result, error) in
            guard error == nil, let result = result else {
                // Error handling
                self.resultText = error?.localizedDescription
                return
            }
            // Recognized text
            self.resultText = result.text
            
//            for block in result.blocks {
//                let blockText = block.text
//                let blockLanguages = block.recognizedLanguages
//                let blockCornerPoints = block.cornerPoints
//                let blockFrame = block.frame
//                for line in block.lines {
//                    let lineText = line.text
//                    let lineLanguages = line.recognizedLanguages
//                    let lineCornerPoints = line.cornerPoints
//                    let lineFrame = line.frame
//                    for element in line.elements {
//                        let elementText = element.text
//                        let elementLanguages = element.recognizedLanguages
//                        let elementCornerPoints = element.cornerPoints
//                        let elementFrame = element.frame
//                    }
//                }
//            }
        }
    }
}
