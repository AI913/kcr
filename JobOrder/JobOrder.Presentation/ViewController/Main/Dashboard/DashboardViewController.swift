//
//  DashboardViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/25.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit
import Charts
import SkeletonView

/// DashboardViewControllerProtocol
/// @mockable
protocol DashboardViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// Robotの稼働状態の更新通知
    /// - Parameter status: Robotの稼働状態の配列
    func updateRobotStatusChart(_ status: [MainViewData.RobotState: Int]?)
    /// Robotの実行Taskの更新通知
    /// - Parameter executions: Robotの実行Taskの配列
    func updateExecutionChart(_ executions: [Date: MainViewData.TaskExecution.Status]?)
}

class DashboardViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var robotStatusChartView: PieChartView!
    @IBOutlet weak var executionChartView: CombinedChartView!
    @IBOutlet weak var errorChartView: CombinedChartView!

    // MARK: - Variable
    var presenter: DashboardPresenterProtocol!

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = MainBuilder.Dashboard().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setExecutionChartView()
        setErrorChartView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.robotStatusChartView.highlightPerTapEnabled = false
    }
}

// MARK: - Action
extension DashboardViewController {

    @IBAction private func touchUpSyncButton(_ sender: UIButton) {
        updateExecutionChart(nil)
        presenter?.fetchExecutionStats()
    }
}

// MARK: - Interface Function
extension DashboardViewController: DashboardViewControllerProtocol {

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func updateRobotStatusChart(_ status: [MainViewData.RobotState: Int]?) {
        updateRobotStatusChartView(status)
    }

    func updateExecutionChart(_ executions: [Date: MainViewData.TaskExecution.Status]?) {
        drawTransactionChartView(executions)
        drawErrorChartView(executions)
    }
}

// MARK: - Private Function
extension DashboardViewController {

    private func setExecutionChartView() {
        executionChartView.xAxis.labelPosition = .bottom
        executionChartView.leftAxis.valueFormatter = ChartAxisValueFormatter(.decimal)
        executionChartView.leftAxis.axisMinimum = 0
        executionChartView.rightAxis.enabled = false
        executionChartView.pinchZoomEnabled = false
        executionChartView.doubleTapToZoomEnabled = false
    }

    private func setErrorChartView() {
        errorChartView.xAxis.labelPosition = .bottom
        errorChartView.leftAxis.valueFormatter = ChartAxisValueFormatter(.decimal)
        errorChartView.leftAxis.axisMinimum = 0
        errorChartView.rightAxis.valueFormatter = ChartAxisValueFormatter(.percent)
        errorChartView.rightAxis.axisMinimum = 0
        errorChartView.rightAxis.drawGridLinesEnabled = false
        errorChartView.pinchZoomEnabled = false
        errorChartView.doubleTapToZoomEnabled = false
    }

    private func updateRobotStatusChartView(_ robotState: [MainViewData.RobotState: Int]?) {
        var entries = [PieChartDataEntry]()
        var colors = [NSUIColor]()

        guard let robotState = robotState else {
            robotStatusChartView.data = nil
            return
        }

        robotState.sorted(by: { $0.0.sortOrder < $1.0.sortOrder }).forEach {
            let entry = PieChartDataEntry(value: Double($0.value), label: $0.key.displayName)
            entries.append(entry)
            colors.append($0.key.color)
        }
        let dataSet = PieChartDataSet(entries: entries, label: nil)
        dataSet.setColors(colors, alpha: 0.8)
        dataSet.valueFormatter = ChartValueFormatter(.decimal)
        // self.robotStatusChartView.animate(xAxisDuration: 1.0)
        robotStatusChartView.data = PieChartData(dataSet: dataSet)
    }

    private func drawTransactionChartView(_ executions: [Date: MainViewData.TaskExecution.Status]?) {
        let data = CombinedChartData()
        var entries = [BarChartDataEntry]()

        guard let executions = executions else {
            executionChartView.data = nil
            return
        }

        let sortedTransactions = executions.sorted(by: { $0.0 < $1.0 })
        let startDate = sortedTransactions[0].key

        for i in 0..<sortedTransactions.count {
            // entries.append(BarChartDataEntry(x: Double(i), yValues: sortedTransactions[i].value.array()))
            entries.append(BarChartDataEntry(x: Double(i), yValues: Array()))
        }

        let dataSet = BarChartDataSet(entries: entries, label: nil)
        dataSet.valueFormatter = ChartValueFormatter(.decimal)
        dataSet.axisDependency = .left
        dataSet.colors = [ .systemBlue, .systemRed, .systemOrange, .systemGray, .systemGray2]
        dataSet.stackLabels = ["succeeded", "failed", "rejected", "canceled", "removed"]
        dataSet.highlightEnabled = false
        data.barData = BarChartData(dataSet: dataSet)
        data.barData.barWidth = 0.5
        executionChartView.xAxis.valueFormatter = ChartAxisDateFormatter(startDate)
        executionChartView.xAxis.axisMinimum = data.xMin - 0.5
        executionChartView.xAxis.axisMaximum = data.xMax + 0.5
        executionChartView.animate(yAxisDuration: 1.0)
        executionChartView.data = data
    }

    private func drawErrorChartView(_ executions: [Date: MainViewData.TaskExecution.Status]?) {
        let data = CombinedChartData()
        var lineEntries = [ChartDataEntry]()
        var barEntries = [BarChartDataEntry]()

        guard let executions = executions else {
            errorChartView.data = nil
            return
        }

        let sortedTransactions = executions.sorted(by: { $0.0 < $1.0 })
        let startDate = sortedTransactions[0].key

        for i in 0..<sortedTransactions.count {
            // let transaction = sortedTransactions[i]
            // let errorCount = transaction.value.failed
            // let errorRate = errorCount / transaction.value.total()
            let errorCount = Double(0)
            let errorRate = Double(0)
            lineEntries.append(ChartDataEntry(x: Double(i), y: errorRate))
            barEntries.append(BarChartDataEntry(x: Double(i), y: errorCount))
        }

        let barDataSet = BarChartDataSet(entries: barEntries, label: L10n.errorCount)
        barDataSet.valueFormatter = ChartValueFormatter(.decimal)
        barDataSet.axisDependency = .left
        barDataSet.colors = [.systemOrange]
        barDataSet.highlightEnabled = false
        data.barData = BarChartData(dataSets: [barDataSet])
        data.barData.barWidth = 0.5
        let lineDataSet = LineChartDataSet(entries: lineEntries, label: L10n.errorRate)
        lineDataSet.valueFormatter = ChartValueFormatter(.percent)
        lineDataSet.axisDependency = .right
        lineDataSet.colors = [.systemRed]
        lineDataSet.drawCirclesEnabled = false
        data.lineData = LineChartData(dataSet: lineDataSet)
        errorChartView.xAxis.valueFormatter = ChartAxisDateFormatter(startDate)
        errorChartView.xAxis.axisMinimum = data.xMin - 0.5
        errorChartView.xAxis.axisMaximum = data.xMax + 0.5
        errorChartView.animate(yAxisDuration: 1.0)
        errorChartView.data = data
    }

    private class ChartValueFormatter: NSObject, IValueFormatter {
        let numFormatter: NumberFormatter

        init(_ style: NumberFormatter.Style) {
            self.numFormatter = NumberFormatter()
            self.numFormatter.numberStyle = style
            self.numFormatter.groupingSeparator = ","
            self.numFormatter.groupingSize = 3
        }

        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            return self.numFormatter.string(from: value as NSNumber)!
        }
    }

    private class ChartAxisDateFormatter: NSObject, IAxisValueFormatter {
        let dateFormatter: DateFormatter
        let startDate: Date

        init(_ startDate: Date) {
            self.dateFormatter = DateFormatter()
            self.dateFormatter.setLocalizedDateFormatFromTemplate("Md")
            self.startDate = startDate
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return self.dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: Int(value), to: self.startDate)!)
        }
    }

    private class ChartAxisValueFormatter: NSObject, IAxisValueFormatter {
        let numFormatter: NumberFormatter

        init(_ style: NumberFormatter.Style) {
            self.numFormatter = NumberFormatter()
            self.numFormatter.numberStyle = style
            self.numFormatter.groupingSeparator = ","
            self.numFormatter.groupingSize = 3
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return self.numFormatter.string(from: value as NSNumber)!
        }
    }
}
