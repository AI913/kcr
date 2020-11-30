//
//  TaskDetailRobotSelectionViewCell.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class TaskDetailRobotSelectionCollectionViewCell: UICollectionViewCell, UICollectionViewCellWithAutoSizing {
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var robotImageView: UIImageView!
    @IBOutlet weak var robotNameLabel: UILabel!
    @IBOutlet weak var robotTypeLabel: UILabel!
    @IBOutlet private weak var checkmarkImage: UIImageView!
    @IBOutlet weak var CircularProgress: TaskDetailRobotSelectionCircularProgressView!

    // MARK: - Constant
    static let identifier: String = "TaskDetailRobotSelectionCollectionViewCell"
    private var presenter: TaskDetailRobotSelectionPresenterProtocol!

    func inject(presenter: TaskDetailRobotSelectionPresenterProtocol) {        self.presenter = presenter
    }

    // MARK: - Override function (view lifecycle)
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedBackgroundView = UIView(frame: self.bounds)
        selectedBackgroundView.backgroundColor = .secondarySystemFill
        selectedBackgroundView.alpha = self.alpha * 0.5
        self.selectedBackgroundView = selectedBackgroundView
    }

    // MARK: - Override function
    override var isHighlighted: Bool {
        didSet {}
    }

    override var isSelected: Bool {
        didSet {}
    }

    func setItem(_ indexPath: IndexPath) {
        robotNameLabel?.text = toLabelText(presenter?.displayName(indexPath.row))
        robotTypeLabel?.text = toLabelText(presenter?.type(indexPath.row))
        let status: TaskDetailViewData.Command.Status = .init(presenter?.status(indexPath.row) ?? "")

        presenter?.image(index: indexPath.row) {
            guard let data = $0 else { return }
            self.robotImageView.image = UIImage(data: data)
        }
        let successCount = presenter?.success(indexPath.row) ?? 0
        let failCount = presenter?.failure(indexPath.row) ?? 0
        let errorCount = presenter?.error(indexPath.row) ?? 0
        let naCount = presenter?.na(indexPath.row) ?? 0

        // Code for the status image view
        //        let status: MainViewData.TaskExecution.Status = .init(presenter?.status() ?? "")
        statusImageView.frame = statusImageView.frame.offsetBy(dx: 0, dy: 0)
        statusImageView.image = status.imageName.withRenderingMode(.alwaysTemplate)
        statusImageView.tintColor = status.imageColor

        // Code for the circular progess indicator

        CircularProgress.invalidateIntrinsicContentSize() // change frame size dynamically
        CircularProgress.frame = CGRect(x: .zero,
                                        y: .zero,
                                        width: self.frame.width * 0.9,
                                        height: self.frame.height * 0.2)
        CircularProgress.trackColor = UIColor.lightGray
        CircularProgress.progressColor = UIColor.blue
        CircularProgress.backgroundColor = nil
        CircularProgress.trackLineWidth = 1.0

        let fullValue = (successCount + failCount + errorCount + naCount)
        var nValue: Float = 1
        if fullValue == 0 {
            nValue = 0
        } else {
            nValue = Float((successCount + failCount + errorCount) / fullValue)
        }

        CircularProgress.setProgressWithAnimation(duration: 1.0, value: nValue)
        CircularProgress.progress = nValue
        CircularProgress.addSubview(statusImageView)
        statusImageView.image = status.imageName.withRenderingMode(.alwaysTemplate)
    }

}
