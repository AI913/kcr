//
//  RecognitionLibraryTestViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkObjectLibraryTestViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableview: UITableView!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var bottomButton: UIButton!
    @IBOutlet private weak var logLabel: UILabel!

    // MARK: - Variable
    private var data: ActionEntryViewData!

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeBack()
        setup()
    }

    func inject(data: ActionEntryViewData) {
        self.data = data
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension WorkObjectLibraryTestViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.works.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: WorkObjectLibraryTestTableViewCell.identifier, for: indexPath)
        guard let cell = _cell as? WorkObjectLibraryTestTableViewCell else {
            return _cell
        }
        cell.inject(data: data)
        cell.setRow(indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Action
extension WorkObjectLibraryTestViewController {

    @IBAction private func touchUpInsideSubmitButton(_ sender: UIButton) {
    }
}

// MARK: - Private Function
extension WorkObjectLibraryTestViewController {

    private func setup() {
        tableview?.tableFooterView = UIView(frame: .zero)
        titleLabel?.text = data.workLibrary?.name
        navigationItem.title = L10n.WorkObjectLibraryTest.title
        navigationItem.leftBarButtonItem?.title = L10n.WorkObjectLibraryTest.leftButton
        previewImageView?.image = data.workLibrary?.workImage?.image
        bottomButton?.setTitle(L10n.WorkObjectLibraryTest.bottomButton, for: .normal)
    }
}
