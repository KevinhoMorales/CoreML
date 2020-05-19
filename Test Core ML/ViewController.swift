//
//  ViewController.swift
//  CustomVisionMicrosoftToCoreML
//
//  Created by Sayalee on 6/28/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

import UIKit
import AVKit
import Vision

enum Test: String {
    case despegue = "gesto"
    case aterrizaje = "Aterrizaje"
    case avance = "Avance"
    case retroceder = "Retroceder"
    case derecha = "Derecha"
    case izquierda = "Izquierda"
    case eje = "Eje"
}

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var predictionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureCamera() {
        
        //Start capture session
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        captureSession.startRunning()
        
        // Add input for capture
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(captureInput)
        
        // Add preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        // Add output for capture
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Initialise CVPixelBuffer from sample buffer
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        //Initialise Core ML model
        guard let handSignsModel = try? VNCoreMLModel(for: Tests().model) else { return }

        // Create a Core ML Vision request
        let request =  VNCoreMLRequest(model: handSignsModel) { (finishedRequest, err) in

            // Dealing with the result of the Core ML Vision request
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }

            guard let firstResult = results.first else { return }
            var predictionString = ""
            DispatchQueue.main.async {
                switch firstResult.identifier {
                case Test.despegue.rawValue:
                    predictionString = "Si"
                case Test.aterrizaje.rawValue:
                    predictionString = "Victory✌🏽"
                case Test.avance.rawValue:
                    predictionString = "Si"
                case Test.retroceder.rawValue:
                    predictionString = "Victory✌🏽"
                case Test.derecha.rawValue:
                    predictionString = "Victory✌🏽"
                case Test.izquierda.rawValue:
                    predictionString = "Si"
                case Test.eje.rawValue:
                    predictionString = "Victory✌🏽"
                default:
                    break
                }
                self.predictionLabel.text = predictionString + "(\(firstResult.confidence))"
            }
        }

        // Perform the above request using Vision Image Request Handler
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}

