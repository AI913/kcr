//
//  OrderEntryStepView.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class OrderEntryStepView: UIView {

    // MARK: - IBOutlet
    @IBOutlet private weak var selectJobStepLabel: UILabel!
    @IBOutlet private weak var selectJobStepTitleLabel: UILabel!
    @IBOutlet private weak var toSelectRobotsStepImage: UIImageView!
    @IBOutlet private weak var selectRobotsStepLabel: UILabel!
    @IBOutlet private weak var selectRobotsStepTitleLabel: UILabel!
    @IBOutlet private weak var toEntryConditionStepImage: UIImageView!
    @IBOutlet private weak var entryConditionStepLabel: UILabel!
    @IBOutlet private weak var entryConditionStepTitleLabel: UILabel!
    @IBOutlet private weak var toConfirmStepImage: UIImageView!
    @IBOutlet private weak var confirmStepLabel: UILabel!
    @IBOutlet private weak var confirmStepTitleLabel: UILabel!

    // MARK: - IBInspectable

    /// IB interface for current step
    @IBInspectable private var stepValue: Int {
        get {
            return self.step.rawValue
        }
        set (newValue) {
            if let step = Step(rawValue: newValue) {
                self.step = step
            } else {
                self.step = .none
            }
        }
    }

    // MARK: - Variable

    /// Value of current step
    var step: Step = .none {
        didSet {
            self.didSetData()
        }
    }

    // MARK: - Override function (view lifecycle)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.loadNib()
    }

    // MARK: - Private function
    private func loadNib() {
        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed("OrderEntryStepView", owner: self, options: nil)?.first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    private func didSetData() {

        switch self.step {
        case .selectJob:
            self.selectJobStepLabel.backgroundColor = .systemIndigo
            self.selectJobStepLabel.textColor = .white
            self.selectJobStepTitleLabel.textColor = .label
        case .selectRobots:
            self.selectRobotsStepLabel.backgroundColor = .systemIndigo
            self.selectRobotsStepLabel.textColor = .white
            self.selectRobotsStepTitleLabel.textColor = .label
            self.toSelectRobotsStepImage.tintColor = .label
        case .entryCondition:
            self.entryConditionStepLabel.backgroundColor = .systemIndigo
            self.entryConditionStepLabel.textColor = .white
            self.entryConditionStepTitleLabel.textColor = .label
            self.toEntryConditionStepImage.tintColor = .label
        case .confirm:
            self.confirmStepLabel.backgroundColor = .systemIndigo
            self.confirmStepLabel.textColor = .white
            self.confirmStepTitleLabel.textColor = .label
            self.toConfirmStepImage.tintColor = .label
        case .none:
            break
        }
    }

    // MARK: - Enum for order entry step
    enum Step: Int {
        case selectJob = 1
        case selectRobots = 2
        case entryCondition = 3
        case confirm = 4
        case none = 0
    }
}
