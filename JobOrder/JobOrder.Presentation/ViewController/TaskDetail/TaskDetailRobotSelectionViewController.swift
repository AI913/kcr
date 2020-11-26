//
//  TaskDetailRobotSelectionViewController.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2020/11/13.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

protocol TaskDetailRobotSelectionViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// ConfigurationForm画面へ遷移
    func transitionToRobotSelectionScreen()
    /// コレクションを更新
    func reloadCollection()
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)

    /// 画面再描画
    func viewReload()
}

class TaskDetailRobotSelectionViewController: UIViewController {

    @IBOutlet weak var robotCollection: UICollectionView!
    @IBOutlet weak var jobNameLabel: UILabel!
    @IBOutlet weak var createdAtValueLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var CircularProgressView: CircularProgressView!
    @IBOutlet weak var cancelAllTasksButton: UIButton!

    @IBAction func segueButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToJobDetail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToJobDetail" {
            guard segue.destination is JobDetailViewController else { return }            }
    }

    // MARK: - Variable
    var viewData: TaskDetailRobotSelectionViewData!
    var presenter: TaskDetailRobotSelectionPresenterProtocol!
    var taskId: String!
    private var computedCellSize: CGSize?

    func inject(taskId: String) {
        viewData = TaskDetailRobotSelectionViewData(taskId)
        presenter = TaskDetailBuilder.TaskDetailRobotSelection().build(vc: self
                                                                       //, viewData: viewData
        )
        self.taskId = taskId
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        robotCollection?.allowsSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear(taskId: self.taskId)
        setViewItemData()
    }

    //    private let reuseIdentifier = "TaskDetailRobotSelectionCell"
    //
    //    private let itemsPerRow: CGFloat = 2
    //    private let sectionInsets = UIEdgeInsets(top: 50.0,
    //                                             left: 20.0,
    //                                             bottom: 50.0,
    //                                             right: 20.0)

}

// MARK: - Protocol Function
extension TaskDetailRobotSelectionViewController: TaskDetailRobotSelectionViewControllerProtocol {
    func viewReload() {
        setViewItemData()
    }

    func transitionToRobotSelectionScreen() {
        self.perform(segue: StoryboardSegue.OrderEntry.showRobotSelection)
    }

    func reloadCollection() {
        robotCollection?.reloadData()
    }

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool) {
    }
}

extension TaskDetailRobotSelectionViewController {
    private func setViewItemData() {
        jobNameLabel?.text = presenter?.jobName() ?? "Can't be fetched"
        createdAtValueLabel?.attributedText = presenter?.createdAt(textColor: createdAtValueLabel.textColor, font: createdAtValueLabel.font)
        updatedAtLabel?.attributedText = presenter?.updatedAt(textColor: updatedAtLabel.textColor, font: updatedAtLabel.font)
        cancelAllTasksButton?.isEnabled = true
    }
}

// MARK: - Implement UICollectionViewDataSource
extension TaskDetailRobotSelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfItems ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailRobotSelectionCollectionViewCell.identifier, for: indexPath)
        guard let cell = _cell as? TaskDetailRobotSelectionCollectionViewCell else {
            return _cell
        }

        cell.inject(presenter: presenter)
        cell.setItem(indexPath)
        if let presenter = presenter, presenter.isSelected(indexPath: indexPath) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        return cell
    }
}

// MARK: - Collection View Flow Layout Delegate
extension TaskDetailRobotSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard self.computedCellSize == nil else {
            return self.computedCellSize!
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailRobotSelectionCollectionViewCell.identifier, for: indexPath)
        guard let prototypeCell = cell as? TaskDetailRobotSelectionCollectionViewCell,
              let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("CollectionViewCell is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 2)
        self.computedCellSize = cellSize
        return cellSize
    }
}
//UICollectionViewDelegateFlowLayout {
//    //1
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //2
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//
//        return CGSize(width: widthPerItem, height: widthPerItem)
//    }
//
//    //3
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//
//    // 4
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
//}
