//
//  WorkObjectSelectionViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/09/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkObjectSelectionViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var tableview: UITableView!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var bottomButton: UIButton!

    // MARK: - Variable
    private var data: ActionEntryViewData!

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func inject(data: ActionEntryViewData) {
        self.data = data
    }
}

// MARK: - View Controller Event
extension WorkObjectSelectionViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.ActionEntry(segue) {
        case .toWorkObjectEntry:
            guard let indexPath = tableview?.indexPathForSelectedRow else { return }
            if let vc = segue.destination as? WorkBenchSelectionViewController {
                vc.inject(data: data, index: indexPath.row)
            }
        default: break
        }
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension WorkObjectSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.works.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: WorkObjectSelectionTableViewCell.identifier, for: indexPath)
        guard let cell = _cell as? WorkObjectSelectionTableViewCell else {
            return _cell
        }
        cell.inject(data: data)
        cell.setRow(indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        perform(segue: StoryboardSegue.ActionEntry.toWorkObjectEntry, sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Action
extension WorkObjectSelectionViewController {

    @IBAction private func returnActionForSegue(_ segue: UIStoryboardSegue) {
        tableview?.reloadData()
    }

    @IBAction private func touchUpInsideDoneButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - Private Function
extension WorkObjectSelectionViewController {

    private func setup() {
        tableview?.tableFooterView = UIView(frame: .zero)
        tableview?.allowsSelection = data.destTray.count > 1
        previewImageView?.image = data?.workLibrary?.workImage?.image
        subtitle?.text = L10n.WorkObjectSelection.subtitle
        bottomButton?.setTitle(L10n.WorkObjectSelection.bottomButton, for: .normal)
    }
}
