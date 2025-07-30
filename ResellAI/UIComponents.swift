import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

// MARK: - Optimized Camera Components

// MARK: - Clean Camera View
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
    private var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCleanInterface()
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
                        self.showPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Enable camera access in Settings to take photos.",
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
    
    private func setupCleanInterface() {
        view.backgroundColor = .systemBackground
        
        // Clean title
        titleLabel = UILabel()
        titleLabel.text = "Take Photos (\(capturedPhotos.count)/\(maxPhotos))"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Simple instruction
        let instructionLabel = UILabel()
        instructionLabel.text = "Multiple angles for better analysis"
        instructionLabel.font = .systemFont(ofSize: 16)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        // Clean camera button
        let cameraButton = UIButton(type: .system)
        cameraButton.setTitle("Take Photo", for: .normal)
        cameraButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        cameraButton.backgroundColor = .systemBlue
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.layer.cornerRadius = 16
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        // Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        doneButton.setTitleColor(.systemBlue, for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(finishCapture), for: .touchUpInside)
        view.addSubview(doneButton)
        
        // Cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16)
        cancelButton.setTitleColor(.secondaryLabel, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelCapture), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 200),
            cameraButton.heightAnchor.constraint(equalToConstant: 60),
            
            doneButton.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    @objc private func takePhoto() {
        guard capturedPhotos.count < maxPhotos else {
            showMaxPhotosAlert()
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCameraUnavailableAlert()
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
            showNoPhotosAlert()
        }
    }
    
    @objc private func cancelCapture() {
        dismiss(animated: true)
    }
    
    private func updateTitle() {
        titleLabel.text = "Take Photos (\(capturedPhotos.count)/\(maxPhotos))"
    }
    
    private func showMaxPhotosAlert() {
        showAlert(title: "Max Photos", message: "You can take up to \(maxPhotos) photos.")
    }
    
    private func showCameraUnavailableAlert() {
        showAlert(title: "Camera Unavailable", message: "Camera is not available on this device.")
    }
    
    private func showNoPhotosAlert() {
        showAlert(title: "No Photos", message: "Please take at least one photo.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            // Optimize image immediately
            if let optimizedImage = optimizeImage(image) {
                capturedPhotos.append(optimizedImage)
                updateTitle()
            }
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // Performance optimization for images
    private func optimizeImage(_ image: UIImage) -> UIImage? {
        let maxSize: CGFloat = 1024
        let size = image.size
        
        // Already optimized
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        // Calculate new size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Resize with high quality
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let optimizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return optimizedImage
    }
}

// MARK: - Optimized Photo Library Picker
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
            
            guard !results.isEmpty else { return }
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    defer { group.leave() }
                    
                    if let image = image as? UIImage {
                        // Optimize immediately
                        if let optimized = self.optimizeImage(image) {
                            images.append(optimized)
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.onPhotosSelected(images)
            }
        }
        
        private func optimizeImage(_ image: UIImage) -> UIImage? {
            let maxSize: CGFloat = 1024
            let size = image.size
            
            if size.width <= maxSize && size.height <= maxSize {
                return image
            }
            
            let ratio = min(maxSize / size.width, maxSize / size.height)
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let optimizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return optimizedImage
        }
    }
}

// MARK: - Clean Barcode Scanner
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
        
        func didFailWithError(_ error: String) {
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
        default:
            delegate?.didFailWithError("Camera permission required")
        }
    }
    
    private func initializeScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.didFailWithError("Camera not available")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFailWithError("Camera access failed")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.didFailWithError("Camera configuration failed")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce, .code128, .code39, .code93, .qr]
        } else {
            delegate?.didFailWithError("Scanner configuration failed")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        addCleanOverlay()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func addCleanOverlay() {
        // Clean overlay
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Scan area
        let scanRect = CGRect(x: 50, y: 200, width: view.bounds.width - 100, height: 150)
        let scanRectPath = UIBezierPath(rect: scanRect)
        let overlayPath = UIBezierPath(rect: overlayView.bounds)
        overlayPath.append(scanRectPath.reversing())
        
        let overlayLayer = CAShapeLayer()
        overlayLayer.path = overlayPath.cgPath
        overlayLayer.fillRule = .evenOdd
        overlayView.layer.addSublayer(overlayLayer)
        
        // Simple instruction
        let instructionLabel = UILabel()
        instructionLabel.text = "Scan barcode"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        instructionLabel.textAlignment = .center
        instructionLabel.frame = CGRect(x: 20, y: scanRect.maxY + 30, width: view.bounds.width - 40, height: 30)
        overlayView.addSubview(instructionLabel)
        
        // Cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
        guard !hasScanned else { return }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            guard isValidBarcode(stringValue) else { return }
            
            hasScanned = true
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            delegate?.didScanBarcode(stringValue)
        }
    }
    
    private func isValidBarcode(_ code: String) -> Bool {
        let numericCode = code.filter { $0.isNumber }
        let validLengths = [8, 10, 12, 13, 14]
        return validLengths.contains(numericCode.count) && numericCode.count >= 8
    }
}

// MARK: - Clean Auto Listing View
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
                    Text("Auto Listing")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    CleanItemPreview(item: item)
                    
                    if generatedListing.isEmpty {
                        Button(action: generateListing) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Generating...")
                                } else {
                                    Image(systemName: "doc.text")
                                    Text("Generate Listing")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                        .disabled(isGenerating)
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Generated Listing")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ScrollView {
                                Text(generatedListing)
                                    .font(.body)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .frame(maxHeight: 300)
                            
                            HStack(spacing: 12) {
                                Button("Edit") {
                                    showingEditSheet = true
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                
                                Button("Share") {
                                    showingShareSheet = true
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button("Copy") {
                                copyToClipboard()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                        }
                    }
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
            generatedListing = createOptimizedListing()
        }
    }
    
    private func createOptimizedListing() -> String {
        return """
        \(item.title)
        
        Condition: \(item.condition)
        \(item.description)
        
        Details:
        • Brand: \(item.brand)
        • Size: \(item.size)
        • Color: \(item.colorway)
        • Code: \(item.inventoryCode)
        
        Fast shipping with tracking
        30-day returns accepted
        
        Keywords: \(item.keywords.joined(separator: " "))
        
        Starting: $\(String(format: "%.2f", item.suggestedPrice * 0.8))
        Buy Now: $\(String(format: "%.2f", item.suggestedPrice))
        """
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatedListing
    }
}

// MARK: - Clean Item Preview
struct CleanItemPreview: View {
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
                    
                    Text(item.inventoryCode)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                HStack {
                    DetailChip(title: "Price", value: "$\(String(format: "%.0f", item.suggestedPrice))", color: .green)
                    DetailChip(title: "Condition", value: item.condition, color: .blue)
                    
                    if !item.size.isEmpty {
                        DetailChip(title: "Size", value: item.size, color: .purple)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct DetailChip: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Clean Listing Edit View
struct ListingEditView: View {
    @Binding var listing: String
    @Environment(\.presentationMode) var presentationMode
    @State private var editedListing: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Listing")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                TextEditor(text: $editedListing)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
                
                Button("Save Changes") {
                    listing = editedListing
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)
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
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
