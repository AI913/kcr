//
//  JobEntryStepView.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/12.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobEntryStepView: UIView {

    // MARK: - IBOoutlet

    /// Label > General Step
    @IBOutlet private weak var generalStepLabel: UILabel!

    /// Label > General Step Title
    @IBOutlet private weak var generalStepTitleLabel: UILabel!

    /// Image > To Flow Step
    @IBOutlet private weak var toFlowStepImage: UIImageView!

    /// Label > Flow Step
    @IBOutlet private weak var flowStepLabel: UILabel!

    /// Label > Flow Step Title
    @IBOutlet private weak var flowStepTitleLabel: UILabel!

    /// Image > To Entry Condition Step
    @IBOutlet private weak var toEntryConditionStepImage: UIImageView!

    /// Label > Entry Condition Step
    @IBOutlet private weak var entryConditionStepLabel: UILabel!

    /// Label > Entry Condition Step Title
    @IBOutlet private weak var entryConditionStepTitleLabel: UILabel!

    /// Image > To Confirm Step
    @IBOutlet private weak var toConfirmStepImage: UIImageView!

    /// Label > Confirm Step
    @IBOutlet private weak var confirmStepLabel: UILabel!

    /// Label > Confirm Step Title
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
        let view = bundle.loadNibNamed("JobEntryStepView", owner: self, options: nil)?.first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    private func didSetData() {

        switch self.step {
        case .general:
            self.generalStepLabel.backgroundColor = .systemIndigo
            self.generalStepLabel.textColor = .white
            self.generalStepTitleLabel.textColor = .label
        case .entryCondition:
            self.entryConditionStepLabel.backgroundColor = .systemIndigo
            self.entryConditionStepLabel.textColor = .white
            self.entryConditionStepTitleLabel.textColor = .label
        // self.toEntryConditionStepImage.tintColor = .label
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
        case general = 1
        case entryCondition = 2
        case confirm = 3
        case none = 0
    }

}
