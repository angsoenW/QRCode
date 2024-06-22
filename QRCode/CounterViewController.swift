//
//  CounterViewController.swift
//  QRCode
//
//  Created by Jasper Wang on 6/15/24.
//

import UIKit

class CounterViewController: UIViewController {

    var qrCodeCountLabel: UILabel!
    var qrCodeCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Setup the counter label
        qrCodeCountLabel = UILabel()
        qrCodeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        qrCodeCountLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        qrCodeCountLabel.textColor = .white
        qrCodeCountLabel.textAlignment = .center
        qrCodeCountLabel.font = UIFont.boldSystemFont(ofSize: 24)
        qrCodeCountLabel.text = "QR Codes Scanned: \(qrCodeCount)"
        view.addSubview(qrCodeCountLabel)

        // Setup the constraints for the label
        NSLayoutConstraint.activate([
            qrCodeCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrCodeCountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            qrCodeCountLabel.widthAnchor.constraint(equalToConstant: 300),
            qrCodeCountLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func updateCounter(count: Int) {
        qrCodeCount = count
        qrCodeCountLabel.text = "QR Codes Scanned: \(qrCodeCount)"
    }
}
