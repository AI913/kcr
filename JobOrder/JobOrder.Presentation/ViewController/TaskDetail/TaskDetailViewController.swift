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
            //                && self.taskData?.status == .inProgress
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        // chartDescriptionが表示されない状態なので、UILabelで表示しています
        //        pieChartView.chartDescription?.text = "Information: \(String(describing: presenter.remarks()))"
        //        pieChartView.chartDescription?.textColor = UIColor.black
        //        pieChartView.chartDescription?.position = CGPoint(x: 50, y: 50)
        //        pieChartView.chartDescription?.font = .systemFont(ofSize: 20)
        //        pieChartView.chartDescription?.textAlign = .center

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear(taskId: self.taskId, robotId: self.robotId)

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

        //        createdAtValueLabel.showSkeleton()
        //        lastUpdatedAtValueLabel.showSkeleton()
        //        robotsValueLabel.showSkeleton()
        //        jobValueLabel.showSkeleton()

        //        startConditionValueLabel.showSkeleton()
        //        exitConditionValueLabel.showSkeleton()
        //        numberOfRunsValueLabel.showSkeleton()

        //self.processing = true
        //        AWSIoTClient.shared.describeJob(jobId: navigationController.form.awsJobId) { (state, job, documentSource, error) -> Void in
        //
        //            guard state == .completed, let job = job, let jobId = job.jobId else {
        //                DispatchQueue.main.async {
        //                    self.presentSingleAlert(error, "An error occurred in 'describe job' process.") { (action) -> Void in
        //                        self.processing = false
        //                        self.dismiss(animated: true)
        //                    }
        //                }
        //                return
        //            }
        //
        //            DispatchQueue.main.async {
        //                self.taskData = Task(job)
        //            }
        //
        //            AWSS3Client.shared.getData(bucket: AWSConstants.S3.Bucket.jobDocument, key: jobId) { (state, result, error) -> Void in
        //
        //                guard state == .completed, let result = result else {
        //                    DispatchQueue.main.async {
        //                        self.processing = false
        //                        self.presentSingleAlert(error, "An error occurred in 'get text' process.")
        //                    }
        //                    return
        //                }
        //
        //                print(String(data: result, encoding: .utf8)!)
        //
        //                let documentData: TaskDocument
        //                do {
        //                    documentData = try JSONDecoder().decode(TaskDocument.self, from: result)
        //                } catch let error {
        //                    DispatchQueue.main.async {
        //                        self.presentSingleAlert(error, "An error occurred in pasrse job document process.") { (action) -> Void in
        //                            self.processing = false
        //                            self.dismiss(animated: true)
        //                        }
        //                    }
        //                    return
        //                }
        //                DispatchQueue.main.async {
        //                    self.processing = false
        //                    self.documentData = documentData
        //                }
        //            }

        /*
         AWSIoTClient.shared.getJobDocument(jobId: navigationController.form.awsJobId) { (state, document, error) -> Void in

         guard state == .completed, let document = document?.data(using: .utf8) else {
         DispatchQueue.main.async {
         self.presentSingleAlert(error, "An error occurred in 'get job document' process.") { (action) -> Void in
         self.processing = false
         self.dismiss(animated: true)
         }
         }
         return
         }

         let documentData: AWSIoTClient.JobDocument
         do {
         documentData = try JSONDecoder().decode(AWSIoTClient.JobDocument.self, from: document)

         } catch let error {
         DispatchQueue.main.async {
         self.presentSingleAlert(error, "An error occurred in pasrse job document process.") { (action) -> Void in
         self.processing = false
         self.dismiss(animated: true)
         }
         }
         return
         }

         print(documentData)
         print(documentData.distFileUrl)
         //let url = URL(string: documentData.distFileUrl)!

         /*
         AWSCognitoClient.shared.getSession() { (state, session, error) -> Void in
         HTTPRequest<TaskDocument>().get(url: url, token: session.idToken) { (result, error) -> Void in
         DispatchQueue.main.async {
         if let error = error {
         self.presentSingleAlert(error)
         self.processing = false
         return
         }
         self.documentData = result
         self.processing = false
         }
         }
         }
         */
         }
         */
        //        }
    }
}

// MARK: - Action
extension TaskDetailViewController {

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @IBAction private func touchUpInsideCancelTaskButton(_ sender: UIButton) {

        //self.processing = true

        //        AWSIoTClient.shared.cancelJob(jobId: navigationController.form.awsJobId) { (state, id, arn, error) -> Void in
        //
        //            guard state == .completed else {
        //                DispatchQueue.main.async {
        //                    self.processing = false
        //                    self.presentSingleAlert(error, "An error occurred in 'cancel job' process.")
        //                }
        //                return
        //            }
        //
        //            DispatchQueue.main.async {
        //                self.processing = false
        //                self.presentSingleAlert("Info", "Task is canceled.") { (action) -> Void in
        //                    self.dismiss(animated: true)
        //                }
        //            }
        //
        //        }
    }
}

// MARK: - Protocol Function
extension TaskDetailViewController: TaskDetailViewControllerProtocol {

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

        //        guard let data = self.taskData else {
        //            fatalError()
        //        }

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long

        createdAtValueLabel.hideSkeleton()
        lastUpdatedAtValueLabel.hideSkeleton()
        robotsValueLabel.hideSkeleton()

        //        createdAtLabel.text = self.toLabelText(self.toDateString(data.createdAt))
        //        createdAtLabel.isEnabled = self.hasLabelText(self.toDateString(data.createdAt))
        //        lastUpdatedAtLabel.text = self.toLabelText(self.toDateString(data.lastUpdatedAt))
        //        lastUpdatedAtLabel.isEnabled = self.hasLabelText(self.toDateString(data.lastUpdatedAt))
        //        completedAtLabel.text = self.toLabelText(self.toDateString(data.completedAt))
        //        completedAtLabel.isEnabled = self.hasLabelText(self.toDateString(data.completedAt))
        //        robotsValueLabel.text = self.toLabelText({ (_ data: Task) -> String? in
        //            guard let targets = data.targets else {
        //                return nil
        //            }
        //            return targets.map {
        //                let arn = $0
        //                let robot = DataManager.shared.robots.first { $1.thing.thingArn == arn }
        //                if let robot = robot {
        //                    return robot.value.thingName
        //                }
        //                else {
        //                    return "Unknown".localized
        //                }
        //            }.joined(separator: "\n")
        //        }(data))
        //        self.remarksValueLabel.text = self.toLabelText(data.detail)
        //        self.remarksValueLabel.isEnabled = self.hasLabelText(data.detail)
    }

    private func didSetDocumentData() {

        //        guard let documentData = self.documentData else {
        //            fatalError()
        //        }

        jobValueLabel.hideSkeleton()

        //        jobValueLabel.text = self.toLabelText({ (_ documentData: TaskDocument) -> String? in
        //            guard let jobDataId = documentData.jobDataId, let job = DataManager.shared.jobs[jobDataId] else {
        //                return nil
        //            }
        //            return job.displayName
        //        }(documentData))
        //        startConditionValueLabel.text = self.toLabelText(documentData.startCondition?.displayName)
        //        exitConditionValueLabel.text = self.toLabelText(documentData.exitCondition?.displayName)
        //        numberOfRunsValueLabel.text = self.toLabelText(documentData.numberOfRuns)
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

}
