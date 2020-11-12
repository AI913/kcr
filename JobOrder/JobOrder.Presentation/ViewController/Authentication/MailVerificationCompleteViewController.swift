//
//  MailVerificationCompleteViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/26.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit

/// MailVerificationCompleteViewController
class MailVerificationCompleteViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var closeButton: UIButton!

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
}

// MARK: - Action
extension MailVerificationCompleteViewController {

    @IBAction private func touchUpInsideCloseButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
