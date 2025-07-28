import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Camera and Photo Components

// MARK: - Camera View
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
    }
    
    private func setupInterface() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "📸 Take Photos (0/\(maxPhotos))"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Take multiple angles for best analysis"
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
        if let titleLabel = view.subviews.compactMap({ $0 as? UILabel }).first {
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
}

// MARK: - Photo Library Picker
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
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.parent.onPhotosSelected(images)
            }
        }
    }
}

// MARK: - Barcode Scanner View
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
            parent.scannedCode = code
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

protocol ScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }
    
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get camera")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add video input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce, .code128, .code39]
        } else {
            print("Could not add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        addScannerOverlay()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
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
        instructionLabel.text = "📱 Scan barcode for instant analysis"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        instructionLabel.textAlignment = .center
        instructionLabel.frame = CGRect(x: 20, y: scanRect.maxY + 20, width: view.bounds.width - 40, height: 30)
        overlayView.addSubview(instructionLabel)
        
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
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            delegate?.didScanBarcode(stringValue)
        }
    }
}

// MARK: - Improved Prospect Analysis Result View
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
                        
                        if !analysis.condition.isEmpty {
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
                            .font(.title)
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
                            .font(.title)
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
                            .font(.title)
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
                        Text(analysis.recommendation.title)
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
                                    Text(sale.condition)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                    
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
                        color: analysis.competitorCount > 100 ? .red : .green
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
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .cornerRadius(16)
            
            // Sourcing Tips
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
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Generating...")
                                } else {
                                    Image(systemName: "wand.and.stars")
                                    Text("🤖 Generate Complete eBay Listing")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
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
            generatedListing = generateEbayListing(for: item)
        }
    }
    
    private func generateEbayListing(for item: InventoryItem) -> String {
        return """
        🔥 \(item.title) 🔥
        
        ⭐ CONDITION: \(item.condition) - \(item.description)
        
        📦 FAST SHIPPING:
        • Same or next business day shipping
        • Carefully packaged with tracking
        • 30-day return policy
        
        💎 ITEM DETAILS:
        • Category: \(item.category)
        • Keywords: \(item.keywords.joined(separator: ", "))
        • Authentic & Verified
        • Inventory Code: \(item.inventoryCode)
        
        🎯 WHY BUY FROM US:
        ✅ Top-rated seller
        ✅ 100% authentic items
        ✅ Fast & secure shipping
        ✅ Excellent customer service
        
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
        VStack(spacing: 12) {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if !item.inventoryCode.isEmpty {
                        Text(item.inventoryCode)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                HStack {
                    Text("Price:")
                    Spacer()
                    Text(String(format: "$%.2f", item.suggestedPrice))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Condition:")
                    Spacer()
                    Text(item.condition)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
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
