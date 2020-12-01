//
//  TaskDetailViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit
import Charts

/// TaskDetailViewControllerProtocol
/// @mockable
protocol TaskDetailViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)

    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)

    /// 画面再描画
    func viewReload()
}

class TaskDetailViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var cancelTaskButton: UIButton!
    @IBOutlet weak var jobValueLabel: UILabel!
    @IBOutlet weak var createdAtValueLabel: UILabel!
    @IBOutlet weak var lastUpdatedAtValueLabel: UILabel!
    @IBOutlet weak var robotsValueLabel: UILabel!
    @IBOutlet weak var startedAtValueLabel: UILabel!
    @IBOutlet weak var exitedAtValueLabel: UILabel!
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var CircularProgress: CircularProgressView!
    @IBOutlet weak var remarksLabel: UILabel!
    // MARK: - Variable
    var taskId: String!
    var robotId: String!
    var presenter: TaskDetailPresenterProtocol!
    private var processing: Bool! {
        didSet {
            self.cancelTaskButton.isEnabled = !self.processing
        }
    }

    func inject(jobId: String, robotId: String) {
        presenter = TaskDetailBuilder.TaskDetail().build(vc: self)
        self.taskId = jobId
        self.robotId = robotId
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelTaskButton.setTitleColor(.tertiaryLabel, for: .disabled)

        if (self.navigationController?.viewControllers.count)! == 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(dismissSelf))
            self.navigationController?.navigationBar.tintColor = UIColor.systemRed
        }
        else{
            self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
        }
    }

    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear(taskId: self.taskId, robotId: self.robotId)
        setViewItemData()
    }
}

// MARK: - Action
extension TaskDetailViewController {

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @IBAction private func touchUpInsideCancelTaskButton(_ sender: UIButton) {
    }
}

// MARK: - Protocol Function
extension TaskDetailViewController: TaskDetailViewControllerProtocol {
    func viewReload() {
        setViewItemData()
    }

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool) {
    }
}

// MARK: - Private Function
extension TaskDetailViewController {

    private func didSetTaskData() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long

        createdAtValueLabel.hideSkeleton()
        lastUpdatedAtValueLabel.hideSkeleton()
        robotsValueLabel.hideSkeleton()
    }

    private func didSetDocumentData() {
        jobValueLabel.hideSkeleton()
    }

    private func toDateString(_ date: Date?) -> String? {
        guard let date = date, date.timeIntervalSince1970 != 0 else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter.string(from: date)
    }

    private func setViewItemData() {
        jobValueLabel?.text = presenter?.jobName()
        let successCount = presenter?.success() ?? 0
        let failCount = presenter?.failure() ?? 0
        let errorCount = presenter?.error() ?? 0
        let naCount = presenter?.na() ?? 0

        createdAtValueLabel.attributedText = presenter?.createdAt(textColor: createdAtValueLabel.textColor, font: createdAtValueLabel.font)
        lastUpdatedAtValueLabel.attributedText = presenter?.updatedAt(textColor: lastUpdatedAtValueLabel.textColor, font: lastUpdatedAtValueLabel.font)
        startedAtValueLabel.attributedText = presenter?.startedAt(textColor: startedAtValueLabel.textColor, font: startedAtValueLabel.font)
        exitedAtValueLabel.attributedText = presenter?.exitedAt(textColor: exitedAtValueLabel.textColor, font: exitedAtValueLabel.font)
        durationValueLabel.attributedText = presenter?.duration(textColor: durationValueLabel.textColor, font: durationValueLabel.font)
        statusValueLabel.text = presenter?.status()

        // Code for the status image view
        let status: MainViewData.TaskExecution.Status = .init(presenter?.status() ?? "")
        statusImageView.frame = statusImageView.frame.offsetBy(dx: 0, dy: 0)
        statusImageView.image = status.imageName.withRenderingMode(.alwaysTemplate)
        statusImageView.tintColor = status.imageColor

        remarksLabel.text = presenter?.remarks()

        // Code for the circular progess indicator
        CircularProgress.frame = CGRect(x: .zero,
                                        y: .zero,
                                        width: self.view.frame.width * 0.9,
                                        height: self.view.frame.height * 0.2)
        CircularProgress.invalidateIntrinsicContentSize() // change frame size dynamically
        CircularProgress.trackColor = UIColor.lightGray
        CircularProgress.progressColor = UIColor.blue
        CircularProgress.trackLineWidth = 2.0

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

        // Code for making the pie chart
        let results = ["Success " + String(successCount),
                       "Fail " + String(failCount),
                       "Error " + String(errorCount),
                       "N/A " + String(naCount)]
        let numbers = [successCount, failCount, errorCount, naCount]
        customizeChart(dataPoints: results, values: numbers.map { Double($0) })
    }

    private func customizeChart(dataPoints: [String], values: [Double]) {
        pieChartView.rotationEnabled = false
        pieChartView.isUserInteractionEnabled = false
        pieChartView.extraRightOffset = 5

        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)

        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)

        // 4. Assign it to the chart’s data
        pieChartView.data = pieChartData

        let l = pieChartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .center
        l.orientation = .vertical

        l.font = NSUIFont.systemFont(ofSize: 15, weight: .light)
        l.yEntrySpace = 5
        l.yOffset = 0
        pieChartView.animate(xAxisDuration: 1.4)
    }

    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        let suc_colour = UIColor(red: 102 / 255, green: 178 / 255, blue: 255 / 255, alpha: 1)
        let fail_colour = UIColor(red: 255 / 255, green: 153 / 255, blue: 51 / 255, alpha: 1)
        let err_colour = UIColor(red: 255 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1)
        let na_colour = UIColor(red: 160 / 255, green: 160 / 255, blue: 160 / 255, alpha: 1)

        let colors: [UIColor] = [suc_colour, fail_colour, err_colour, na_colour]

        return colors
    }
}
