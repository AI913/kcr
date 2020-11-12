//
//  ActionEntryStepView.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/12.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class ActionEntryStepView: UIView {

    // MARK: - IBOutlet
    @IBOutlet private weak var selectActionStepLabel: UILabel!
    @IBOutlet private weak var selectActionStepTitleLabel: UILabel!
    @IBOutlet private weak var toSelectWorkbenchStepImage: UIImageView!
    @IBOutlet private weak var selectWorkbenchStepLabel: UILabel!
    @IBOutlet private weak var selectWorkbenchStepTitleLabel: UILabel!
    @IBOutlet private weak var toSelectWorkStepImage: UIImageView!
    @IBOutlet private weak var selectWorkStepLabel: UILabel!
    @IBOutlet private weak var selectWorkStepTitleLabel: UILabel!
    @IBOutlet private weak var toMoveWorkStepImage: UIImageView!
    @IBOutlet private weak var moveWorkStepLabel: UILabel!
    @IBOutlet private weak var moveWorkStepTitleLabel: UILabel!

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
        let view = bundle.loadNibNamed("ActionEntryStepView", owner: self, options: nil)?.first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    private func didSetData() {

        switch self.step {
        case .selectAction:
            self.selectActionStepLabel.backgroundColor = .systemIndigo
            self.selectActionStepLabel.textColor = .white
            self.selectActionStepTitleLabel.textColor = .label
        case .selectWorkbench:
            self.selectWorkbenchStepLabel.backgroundColor = .systemIndigo
            self.selectWorkbenchStepLabel.textColor = .white
            self.selectWorkbenchStepTitleLabel.textColor = .label
            self.toSelectWorkbenchStepImage.tintColor = .label
        case .selectWork:
            self.selectWorkStepLabel.backgroundColor = .systemIndigo
            self.selectWorkStepLabel.textColor = .white
            self.selectWorkStepTitleLabel.textColor = .label
            self.toSelectWorkStepImage.tintColor = .label
        case .selectMove:
            self.moveWorkStepLabel.backgroundColor = .systemIndigo
            self.moveWorkStepLabel.textColor = .white
            self.moveWorkStepTitleLabel.textColor = .label
            self.toMoveWorkStepImage.tintColor = .label
        case .none:
            break
        }
    }

    // MARK: - Enum for order entry step
    enum Step: Int {
        case selectAction = 1
        case selectWorkbench = 2
        case selectWork = 3
        case selectMove = 4
        case none = 0
    }

}
