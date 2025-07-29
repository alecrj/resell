import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - FIXED Camera and Photo Components

// MARK: - Camera View with Error Handling
struct CameraView: UIViewControllerRepresentable {
    let onPhotosSelected: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func didCapturePhotos(_ photos: [UIImage]) {
            parent.onPhotosSelected(photos)
        }
    }
}

protocol CameraDelegate: AnyObject {
    func didCapturePhotos(_ photos: [UIImage])
}

class CameraViewController: UIViewController {
    weak var delegate: CameraDelegate?
    private var capturedPhotos: [UIImage] = []
    private let maxPhotos = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    DispatchQueue.main.async {
                        self.showPermissionDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert()
        @unknown default:
            break
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please enable camera access in Settings to take photos for analysis.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func setupInterface() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "📸 Take Photos (\(capturedPhotos.count)/\(maxPhotos))"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.tag = 100 // Tag for updating
        view.addSubview(titleLabel)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Take multiple angles for best AI analysis"
        instructionLabel.font = .systemFont(ofSize: 16)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .systemGray
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setTitle("📷 Take Photo", for: .normal)
        cameraButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        cameraButton.backgroundColor = .systemBlue
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.layer.cornerRadius = 12
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("✅ Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        doneButton.backgroundColor = .systemGreen
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 12
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(finishCapture), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 200),
            cameraButton.heightAnchor.constraint(equalToConstant: 50),
            
            doneButton.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 200),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func takePhoto() {
        guard capturedPhotos.count < maxPhotos else {
            let alert = UIAlertController(title: "Max Photos Reached", message: "You can take up to \(maxPhotos) photos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(title: "Camera Not Available", message: "Camera is not available on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func finishCapture() {
        if !capturedPhotos.isEmpty {
            delegate?.didCapturePhotos(capturedPhotos)
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "No Photos", message: "Please take at least one photo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func updateUI() {
        if let titleLabel = view.viewWithTag(100) as? UILabel {
            titleLabel.text = "📸 Take Photos (\(capturedPhotos.count)/\(maxPhotos))"
        }
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            capturedPhotos.append(image)
            updateUI()
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Photo Library Picker with Error Handling
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    let onPhotosSelected: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 8
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker
        
        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else {
                print("📷 No photos selected")
                return
            }
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error {
                        print("❌ Error loading image: \(error)")
                    } else if let image = image as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                print("📷 Loaded \(images.count) photos from library")
                self.parent.onPhotosSelected(images)
            }
        }
    }
}

// MARK: - FIXED Barcode Scanner View with Proper Error Handling
struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ScannerDelegate {
        let parent: BarcodeScannerView
        
        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func didScanBarcode(_ code: String) {
            print("📱 Barcode scanned: \(code)")
            parent.scannedCode = code
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func didFailWithError(_ error: String) {
            print("❌ Barcode scanning error: \(error)")
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

protocol ScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
    func didFailWithError(_ error: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var hasScanned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }
    
    private func setupScanner() {
        // Check camera permission first
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            initializeScanner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.initializeScanner()
                    } else {
                        self?.delegate?.didFailWithError("Camera permission denied")
                    }
                }
            }
        case .denied, .restricted:
            delegate?.didFailWithError("Camera permission required for barcode scanning")
            return
        @unknown default:
            delegate?.didFailWithError("Camera permission unknown")
            return
        }
    }
    
    private func initializeScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("❌ Failed to get camera device")
            delegate?.didFailWithError("Camera not available")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("❌ Failed to create video input: \(error)")
            delegate?.didFailWithError("Failed to access camera")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("❌ Could not add video input")
            delegate?.didFailWithError("Could not configure camera")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce, .code128, .code39, .code93, .qr]
        } else {
            print("❌ Could not add metadata output")
            delegate?.didFailWithError("Could not configure barcode scanner")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        addScannerOverlay()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func addScannerOverlay() {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let scanRect = CGRect(x: 50, y: 200, width: view.bounds.width - 100, height: 200)
        let scanRectPath = UIBezierPath(rect: scanRect)
        let overlayPath = UIBezierPath(rect: overlayView.bounds)
        overlayPath.append(scanRectPath.reversing())
        
        let overlayLayer = CAShapeLayer()
        overlayLayer.path = overlayPath.cgPath
        overlayLayer.fillRule = .evenOdd
        overlayView.layer.addSublayer(overlayLayer)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "📱 Scan barcode for instant product lookup"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        instructionLabel.textAlignment = .center
        instructionLabel.frame = CGRect(x: 20, y: scanRect.maxY + 20, width: view.bounds.width - 40, height: 30)
        overlayView.addSubview(instructionLabel)
        
        let statusLabel = UILabel()
        statusLabel.text = "Position barcode within the frame"
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.frame = CGRect(x: 20, y: scanRect.maxY + 50, width: view.bounds.width - 40, height: 20)
        overlayView.addSubview(statusLabel)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cancelButton.frame = CGRect(x: 20, y: 50, width: 80, height: 40)
        cancelButton.addTarget(self, action: #selector(cancelScanning), for: .touchUpInside)
        overlayView.addSubview(cancelButton)
        
        view.addSubview(overlayView)
    }
    
    @objc private func cancelScanning() {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession != nil && !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
        hasScanned = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession != nil && captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Prevent multiple scans
        guard !hasScanned else { return }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Validate barcode format
            guard isValidBarcode(stringValue) else {
                print("❌ Invalid barcode format: \(stringValue)")
                return
            }
            
            hasScanned = true
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            print("✅ Valid barcode scanned: \(stringValue)")
            delegate?.didScanBarcode(stringValue)
        }
    }
    
    private func isValidBarcode(_ code: String) -> Bool {
        // Remove any non-numeric characters and check length
        let numericCode = code.filter { $0.isNumber }
        
        // Valid barcode lengths: UPC-A (12), EAN-13 (13), UPC-E (8), etc.
        let validLengths = [8, 10, 12, 13, 14]
        return validLengths.contains(numericCode.count) && numericCode.count >= 8
    }
}

// MARK: - FIXED Prospect Analysis Result View
struct ImprovedProspectAnalysisResultView: View {
    let analysis: ProspectAnalysis
    
    var body: some View {
        VStack(spacing: 20) {
            // Item Identification Header
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🔍 ITEM IDENTIFIED")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text(analysis.itemName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if !analysis.brand.isEmpty {
                            Text("Brand: \(analysis.brand)")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text("Confidence: \(String(format: "%.0f", analysis.confidence * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Product details row
                    HStack {
                        if !analysis.category.isEmpty {
                            Text(analysis.category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        if !analysis.size.isEmpty {
                            Text("Size: \(analysis.size)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        if !analysis.condition.isEmpty && analysis.condition != "Unknown" {
                            Text(analysis.condition)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.05))
                .cornerRadius(16)
            }
            
            // Pricing Strategy - Most Important Section
            VStack(spacing: 15) {
                Text("💰 PRICING STRATEGY")
                    .font(.headline)
                    .fontWeight(.bold)
                
                // Main pricing cards
                HStack(spacing: 12) {
                    // Max Buy Price
                    VStack(spacing: 8) {
                        Text("MAX PAY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text("$\(String(format: "%.2f", analysis.maxBuyPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text("Don't pay more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Target Buy Price
                    VStack(spacing: 8) {
                        Text("TARGET PRICE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("$\(String(format: "%.2f", analysis.targetBuyPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("Good profit")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Sell Price
                    VStack(spacing: 8) {
                        Text("SELL FOR")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("$\(String(format: "%.2f", analysis.estimatedSellPrice))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Market price")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Profit potential
                HStack {
                    VStack(alignment: .leading) {
                        Text("Potential Profit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", analysis.potentialProfit))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(analysis.potentialProfit > 10 ? .green : .orange)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        Text("Expected ROI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", analysis.expectedROI))%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(analysis.expectedROI > 100 ? .green : analysis.expectedROI > 50 ? .orange : .red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Recommendation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text(analysis.recommendation.emoji)
                            Text(analysis.recommendation.title)
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(analysis.recommendation.color)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(16)
            
            // Recent Sales Data
            if !analysis.recentSales.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("📈 RECENT EBAY SALES")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(analysis.recentSales.prefix(3), id: \.title) { sale in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sale.title)
                                    .font(.body)
                                    .lineLimit(2)
                                
                                HStack {
                                    if !sale.condition.isEmpty {
                                        Text(sale.condition)
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                    
                                    Text("Sold in \(sale.soldIn)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("$\(String(format: "%.2f", sale.price))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text(formatDate(sale.date))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Average sale price
                    if analysis.averageSoldPrice > 0 {
                        HStack {
                            Text("Average Sale Price:")
                                .font(.body)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", analysis.averageSoldPrice))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(16)
            }
            
            // Market Intelligence
            VStack(alignment: .leading, spacing: 12) {
                Text("📊 MARKET INTEL")
                    .font(.headline)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    
                    ProspectStatCard(
                        title: "Demand",
                        value: analysis.demandLevel,
                        color: getDemandColor(analysis.demandLevel)
                    )
                    
                    ProspectStatCard(
                        title: "Competition",
                        value: "\(analysis.competitorCount)",
                        color: analysis.competitorCount > 100 ? .red : analysis.competitorCount > 50 ? .orange : .green
                    )
                    
                    ProspectStatCard(
                        title: "Sell Time",
                        value: analysis.sellTimeEstimate,
                        color: .blue
                    )
                    
                    ProspectStatCard(
                        title: "Risk Level",
                        value: analysis.riskLevel,
                        color: getRiskColor(analysis.riskLevel)
                    )
                }
                
                // Analysis reasons
                if !analysis.reasons.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🎯 Analysis Factors")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ForEach(analysis.reasons, id: \.self) { reason in
                            Text("• \(reason)")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .cornerRadius(16)
            
            // Sourcing Tips
            if !analysis.sourcingTips.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("💡 SOURCING TIPS")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(analysis.sourcingTips, id: \.self) { tip in
                        HStack(alignment: .top) {
                            Text("✓")
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                            Text(tip)
                                .font(.body)
                        }
                    }
                    
                    // Additional insights
                    if analysis.quickFlipPotential {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                            Text("Quick flip potential - high demand item")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    if analysis.holidayDemand {
                        HStack {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.red)
                            Text("Higher demand during holidays")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.02))
        .cornerRadius(20)
    }
    
    private func getDemandColor(_ demand: String) -> Color {
        switch demand.lowercased() {
        case "high": return .green
        case "medium": return .orange
        case "low": return .red
        default: return .gray
        }
    }
    
    private func getRiskColor(_ risk: String) -> Color {
        switch risk.lowercased() {
        case "low": return .green
        case "medium": return .orange
        case "high": return .red
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Prospect Stat Card
struct ProspectStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Photo Placeholder Views
struct PhotoPlaceholderView: View {
    let onTakePhotos: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                )
            
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Take Multiple Photos")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Take up to 8 photos for complete item analysis")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    Text("✓ AI Computer Vision Analysis")
                    Text("✓ Real-time Market Research")
                    Text("✓ Accurate Pricing Strategy")
                    Text("✓ Professional eBay Listing Generation")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .onTapGesture {
            onTakePhotos()
        }
    }
}

struct ProspectingPhotoPlaceholderView: View {
    let onTakePhotos: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.1), .pink.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                )
            
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                VStack(spacing: 8) {
                    Text("Prospecting Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Get instant max buy price for any item")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 4) {
                    Text("✓ Instant Item Identification")
                    Text("✓ Max Buy Price Calculation")
                    Text("✓ Profit Potential Analysis")
                    Text("✓ Buy/Research Recommendation")
                }
                .font(.caption)
                .foregroundColor(.purple)
            }
        }
        .onTapGesture {
            onTakePhotos()
        }
    }
}

// Keep existing Auto Listing View and other components...
// [Rest of the file continues with existing implementations]

// MARK: - Auto Listing View
struct AutoListingView: View {
    let item: InventoryItem
    @State private var generatedListing = ""
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    @State private var showingEditSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🚀 Auto-Generated eBay Listing")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    InventoryItemPreviewCard(item: item)
                    
                    if generatedListing.isEmpty {
                        Button(action: {
                            generateListing()
                        }) {
                            HStack(spacing: 12) {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Generating...")
                                } else {
                                    Image(systemName: "wand.and.stars")
                                        .font(.title2)
                                    Text("🤖 Generate Complete eBay Listing")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isGenerating)
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📝 Generated eBay Listing")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ScrollView {
                                Text(generatedListing)
                                    .font(.body)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .frame(maxHeight: 300)
                            
                            HStack(spacing: 15) {
                                Button(action: {
                                    showingEditSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showingShareSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share/Send")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                copyToClipboard()
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("📋 Copy to Clipboard")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generatedListing])
        }
        .sheet(isPresented: $showingEditSheet) {
            ListingEditView(listing: $generatedListing)
        }
    }
    
    private func generateListing() {
        isGenerating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            generatedListing = generateOptimizedEbayListing(for: item)
        }
    }
    
    private func generateOptimizedEbayListing(for item: InventoryItem) -> String {
        return """
        🔥 \(item.title) 🔥
        
        ⭐ CONDITION: \(item.condition) - \(item.description)
        
        📦 FAST SHIPPING:
        • Same or next business day shipping
        • Carefully packaged with tracking
        • 30-day return policy
        
        💎 ITEM DETAILS:
        • Category: \(item.category)
        • Brand: \(item.brand)
        • Size: \(item.size)
        • Colorway: \(item.colorway)
        • Keywords: \(item.keywords.joined(separator: ", "))
        • Authentic & Verified
        • Inventory Code: \(item.inventoryCode)
        
        🎯 WHY BUY FROM US:
        ✅ Top-rated seller
        ✅ 100% authentic items
        ✅ Fast & secure shipping
        ✅ Excellent customer service
        ✅ Thousands of satisfied customers
        
        📱 QUESTIONS? Message us anytime!
        
        🔍 Search terms: \(item.keywords.joined(separator: " "))
        
        #\(item.keywords.joined(separator: " #"))
        
        Starting bid: $\(String(format: "%.2f", item.suggestedPrice * 0.7))
        Buy It Now: $\(String(format: "%.2f", item.suggestedPrice))
        
        Thank you for shopping with us! 🙏
        """
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatedListing
    }
}

// MARK: - Inventory Item Preview Card
struct InventoryItemPreviewCard: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(spacing: 15) {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if !item.brand.isEmpty {
                            Text(item.brand)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    if !item.inventoryCode.isEmpty {
                        Text(item.inventoryCode)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    
                    ItemDetailChip(title: "Price", value: "$\(String(format: "%.2f", item.suggestedPrice))", color: .green)
                    ItemDetailChip(title: "Condition", value: item.condition, color: .blue)
                    
                    if !item.size.isEmpty {
                        ItemDetailChip(title: "Size", value: item.size, color: .purple)
                    }
                    
                    if !item.colorway.isEmpty {
                        ItemDetailChip(title: "Color", value: item.colorway, color: .orange)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.05))
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Item Detail Chip
struct ItemDetailChip: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Listing Edit View
struct ListingEditView: View {
    @Binding var listing: String
    @Environment(\.presentationMode) var presentationMode
    @State private var editedListing: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("✏️ Edit Your Listing")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                TextEditor(text: $editedListing)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
                
                Button(action: {
                    listing = editedListing
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("💾 Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            editedListing = listing
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
