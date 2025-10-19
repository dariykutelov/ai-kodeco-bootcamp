//
//  CameraView.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 15.10.25.
//

import SwiftUI
import AVFoundation
import Vision
import Combine

/// SwiftUI wrapper around a live camera view
struct CameraView: UIViewRepresentable {
    @ObservedObject var coordinator: Coordinator

    func makeUIView(context: Context) -> CameraPreview {
        let view = CameraPreview()
        coordinator.preview = view
        view.session = coordinator.session
        return view
    }

    func updateUIView(_ uiView: CameraPreview, context: Context) {}

    func makeCoordinator() -> Coordinator {
        coordinator
    }

    // MARK: - Coordinator handles AVCapture + Vision
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
        @Published var isRunning: Bool = false

        let session = AVCaptureSession()
        let videoOutput = AVCaptureVideoDataOutput()
        var preview: CameraPreview?
        private let queue = DispatchQueue(label: "camera.queue")

        override init() {
            super.init()
            setupSession()
        }

        private func setupSession() {
            session.beginConfiguration()
            session.sessionPreset = .medium

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .front),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input)
            else { return }

            session.addInput(input)

            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: queue)
                videoOutput.alwaysDiscardsLateVideoFrames = true
            }

            session.commitConfiguration()
        }

        // Start camera session (background thread)
        func startSession() {
            guard !session.isRunning else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
                DispatchQueue.main.async { self.isRunning = true }
            }
        }

        // Stop camera session (background thread)
        func stopSession() {
            guard session.isRunning else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.stopRunning()
                DispatchQueue.main.async { self.isRunning = false }
            }
        }

        // Receive each camera frame and run Vision face detection
        func captureOutput(_ output: AVCaptureOutput,
                           didOutput sampleBuffer: CMSampleBuffer,
                           from connection: AVCaptureConnection) {
            // For front camera portrait mode, this is the correct orientation.
            let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .upMirrored)

            let request = VNDetectFaceLandmarksRequest { [weak self] request, _ in
                guard let self,
                      let results = request.results as? [VNFaceObservation] else { return }
                DispatchQueue.main.async {
                    self.preview?.drawGooglyEyes(on: results)
                }
            }

            try? handler.perform([request])
        }

    }
}
