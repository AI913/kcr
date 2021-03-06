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

class TaskDetailTaskInformationViewController: UIViewController {

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
    var presenter: TaskDetailTaskInformationPresenterProtocol!
    private var processing: Bool! {
        didSet {
            self.cancelTaskButton.isEnabled = !self.processing
        }
    }

    func inject(taskId: String, robotId: String) {
        presenter = TaskDetailBuilder.TaskDetail().build(vc: self)
        self.taskId = taskId
        self.robotId = robotId
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelTaskButton.setTitleColor(.tertiaryLabel, for: .disabled)
        if self.navigationController?.viewControllers.first != self {
            self.navigationItem.leftBarButtonItem = nil
        }
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

// MARK: - View Controller Event
extension TaskDetailTaskInformationViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.TaskDetail(segue) {
        case .taskDetailTaskInformationToExecutionLog:
            let vc = segue.destination as! TaskDetailExecutionLogViewController
            let viewData = TaskDetailViewData(taskId: taskId, robotId: robotId)
            vc.inject(viewData: viewData)
        default: break
        }
    }

}

// MARK: - Action
extension TaskDetailTaskInformationViewController {

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @IBAction private func touchUpInsideCancelTaskButton(_ sender: UIButton) {
    }

    @IBAction func touchUpInsideShowDetailButton(_ sender: Any) {
        self.perform(segue: StoryboardSegue.TaskDetail.taskDetailTaskInformationToExecutionLog)
    }

}

// MARK: - Protocol Function
extension TaskDetailTaskInformationViewController: TaskDetailViewControllerProtocol {
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
extension TaskDetailTaskInformationViewController {

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

    private func setViewItemData() {
        jobValueLabel?.text = presenter?.jobName()
        let successCount = (presenter?.success() ?? 0)
        let failCount = (presenter?.failure() ?? 0)
        let errorCount = (presenter?.error() ?? 0)
        let naCount = presenter?.na()

        createdAtValueLabel.attributedText = presenter?.createdAt(textColor: createdAtValueLabel.textColor, font: createdAtValueLabel.font)
        lastUpdatedAtValueLabel.attributedText = presenter?.updatedAt(textColor: lastUpdatedAtValueLabel.textColor, font: lastUpdatedAtValueLabel.font)
        startedAtValueLabel.attributedText = presenter?.startedAt(textColor: startedAtValueLabel.textColor, font: startedAtValueLabel.font)
        exitedAtValueLabel.attributedText = presenter?.exitedAt(textColor: exitedAtValueLabel.textColor, font: exitedAtValueLabel.font)
        durationValueLabel.attributedText = presenter?.duration(textColor: durationValueLabel.textColor, font: durationValueLabel.font)
        statusValueLabel.text = presenter?.status()
        robotsValueLabel.text = presenter?.RobotName()

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

        // Code for making the pie chart
        let labels = ["Success", "Fail", "Error"]
        let numbers = [successCount, failCount, errorCount]
        let sum = numbers.reduce(0, +)

        var results = Array(zip(labels, numbers))
        var nValue: Float = 0.0
        if let naCount = naCount, naCount > 0 {
            if sum > 0 {
                nValue = Float(sum) / Float(sum + naCount)
            }
            results.append(("N/A", naCount))
        } else {
            if sum > 0 {
                nValue = 1.0
            }
        }

        CircularProgress.setProgressWithAnimation(duration: 1.0, value: nValue)
        CircularProgress.progress = nValue
        CircularProgress.addSubview(statusImageView)

        let dataPoints = results.map({ String(format: "%@ %d", $0, $1) })
        let values = results.map { Double($1) }
        customizeChart(dataPoints: dataPoints, values: values)
    }

    private func customizeChart(dataPoints: [String], values: [Double]) {
        pieChartView.rotationEnabled = false
        pieChartView.isUserInteractionEnabled = false
        pieChartView.extraRightOffset = 5
        pieChartView.drawEntryLabelsEnabled = false

        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        pieChartDataSet.drawValuesEnabled = false

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
