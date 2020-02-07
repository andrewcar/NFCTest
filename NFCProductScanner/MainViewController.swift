//
//  ViewController.swift
//  NFCProductScanner
//
//  Created by Alfian Losari on 1/26/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import CoreNFC

class MainViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet private var nfcLabel: UILabel!
    var session: NFCNDEFReaderSession?
    let initialText = "Tap NFC logo to begin scan"
    var scanningSKU = false

    @IBAction func scanTapped(_ sender: Any) {
        guard session == nil else { return }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        session?.begin()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nfcLabel.text = initialText
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session = nil
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        nfcLabel.text = initialText
    }
}

// MARK: - NFCVASReaderSessionDelegate

//extension MainViewController: NFCVASReaderSessionDelegate {
//
//    @available(iOS 13.0, *)
//    func readerSession(_ session: NFCVASReaderSession, didReceive responses: [NFCVASResponse]) {
//
//        guard let vasResponse = responses.first else { return }
//
//        print("VAS RESPONSE: \(vasResponse)")
//    }
//
//    @available(iOS 13.0, *)
//    func readerSession(_ session: NFCVASReaderSession, didInvalidateWithError error: Error) {
//        print("VAS ERROR: \(error.localizedDescription)")
//    }
//}

// MARK: - FCNDEFReaderSessionDelegate

extension MainViewController: NFCNDEFReaderSessionDelegate {

    @nonobjc func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {

        guard let ndefMessage = messages.first,
            let record = ndefMessage.records.first,
            record.typeNameFormat == .nfcWellKnown,
            let payloadText = String(data: record.payload, encoding: .utf8) else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            print("NFC PAYLOAD: \(payloadText)")
            let alertController = UIAlertController(title: "NFC", message: payloadText, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alertController, animated: true, completion: nil)
        }

        self.session = nil

        // MARK: - SKU

        guard scanningSKU, let sku = payloadText.split(separator: "/").last else { return }

        guard let product = ProductStore.shared.product(withID: String(sku)) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                let alertController = UIAlertController(title: "Info", message: "SKU not found in catalog", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.presentProductViewController(product: product)
        }
    }

    func presentProductViewController(product: Product) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        vc.product = product
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        present(navVC, animated: true, completion: nil)
    }

    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {

        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }

        // A new session instance is required to read new tags.
        self.session = nil
    }
}
