//
//  AboutAppViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/25.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit

/// AboutAppViewControllerProtocol
/// @mockable
protocol AboutAppViewControllerProtocol: class {}

class AboutAppViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var thingNameLabel: UILabel!

    // MARK: - Variable
    var presenter: AboutAppPresenterProtocol!

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = MainBuilder.AboutApp().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeBack()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appNameLabel.text = presenter?.appName
        appVersionLabel.text = presenter?.appVersion
        thingNameLabel.text = presenter?.thingName
    }
}

// MARK: - Interface function
extension AboutAppViewController: AboutAppViewControllerProtocol {}
