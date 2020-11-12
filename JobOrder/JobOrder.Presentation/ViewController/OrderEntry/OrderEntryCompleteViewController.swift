//
//  OrderEntryCompleteViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class OrderEntryCompleteViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var closeButton: UIButton!

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
}

// MARK: - Action
extension OrderEntryCompleteViewController {

    @IBAction private func touchUpInsideCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
