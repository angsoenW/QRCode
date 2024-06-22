//
//  ViewController.swift
//  QRCode
//
//  Created by Jasper Wang on 6/14/24.
//
import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeCount = 0
    var qrCodeCountLabel: UILabel!
    var detectionBox: UIView!
    var scannedCodeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the camera session
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Your device does not support scanning a code from an item. Please use a device with a camera.")
            return
        }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        // Setup the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start the capture session
        captureSession.startRunning()

        // Setup the counter label
        qrCodeCountLabel = UILabel()
        qrCodeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        qrCodeCountLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        qrCodeCountLabel.textColor = .white
        qrCodeCountLabel.textAlignment = .center
        qrCodeCountLabel.font = UIFont.boldSystemFont(ofSize: 24)
        qrCodeCountLabel.text = "QR Codes Scanned: \(qrCodeCount)"
        view.addSubview(qrCodeCountLabel)

        // Setup the scanned code label
        scannedCodeLabel = UILabel()
        scannedCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        scannedCodeLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        scannedCodeLabel.textColor = .white
        scannedCodeLabel.textAlignment = .center
        scannedCodeLabel.font = UIFont.systemFont(ofSize: 16)
        scannedCodeLabel.numberOfLines = 0
        scannedCodeLabel.text = "Last QR Code Scanned: None"
        view.addSubview(scannedCodeLabel)

        // Setup the constraints for the labels
        NSLayoutConstraint.activate([
            qrCodeCountLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            qrCodeCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrCodeCountLabel.widthAnchor.constraint(equalToConstant: 300),
            qrCodeCountLabel.heightAnchor.constraint(equalToConstant: 40),

            scannedCodeLabel.bottomAnchor.constraint(equalTo: qrCodeCountLabel.topAnchor, constant: -10),
            scannedCodeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scannedCodeLabel.widthAnchor.constraint(equalToConstant: 300),
            scannedCodeLabel.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Setup the detection box
        detectionBox = UIView()
        detectionBox.layer.borderColor = UIColor.green.cgColor
        detectionBox.layer.borderWidth = 4
        detectionBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detectionBox)

        // Setup the constraints for the detection box
        NSLayoutConstraint.activate([
            detectionBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detectionBox.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            detectionBox.widthAnchor.constraint(equalToConstant: 250),
            detectionBox.heightAnchor.constraint(equalToConstant: 250)
        ])

        // Set the rectOfInterest for the metadata output
        view.layoutIfNeeded() // Ensure the layout is updated
        let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: detectionBox.frame)
        metadataOutput.rectOfInterest = rectOfInterest
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }

    func found(code: String) {
        qrCodeCount += 1
        qrCodeCountLabel.text = "QR Codes Scanned: \(qrCodeCount)"
        scannedCodeLabel.text = "Last QR Code Scanned: \(code)"
        
        // Update the counter in the CounterViewController
        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers,
           let counterVC = viewControllers[1] as? CounterViewController {
            counterVC.updateCounter(count: qrCodeCount)
        }
        
        captureSession.stopRunning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.captureSession.startRunning()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
