import SwiftUI // Importuj framework SwiftUI
import AVFoundation // Importuj framework AVFoundation

struct QRScannerView: UIViewRepresentable {
    // Zmienna przechowująca funkcję wywołania zwrotnego po zeskanowaniu kodu QR
    var onCodeScanned: (String) -> Void

    // Tworzenie koordynatora do obsługi wydarzeń związanych ze skanowaniem
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)
    }
    
    // Tworzenie widoku skanera QR
    func makeUIView(context: UIViewRepresentableContext<QRScannerView>) -> UIView {
        let scannerView = UIView()
        scannerView.backgroundColor = .clear
        
        // Konfiguracja sesji przechwytywania
        let captureSession = AVCaptureSession()
        if let captureDevice = AVCaptureDevice.default(for: .video),
           let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
           captureSession.canAddInput(captureDeviceInput) {
            captureSession.addInput(captureDeviceInput)
        } else {
            return scannerView
        }
        
        // Konfiguracja wyjścia metadanych
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return scannerView
        }
        
        // Konfiguracja warstwy podglądu wideo
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        return scannerView
    }
    
    // Aktualizacja widoku skanera QR, ale w tej strukturze nie ma potrzeby niczego aktualizować
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<QRScannerView>) {}
    
    // Klasa koordynatora do obsługi zdarzeń związanych ze skanowaniem
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var scannerView: QRScannerView

        // Inicjalizacja koordynatora z widokiem skanera QR
        init(scannerView: QRScannerView) {
            self.scannerView = scannerView
        }
        
        // Obsługa zdarzenia wyjścia metadanych
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let stringValue = metadataObject.stringValue else { return }
            
            scannerView.onCodeScanned(stringValue)
        }
    }
}
