//
//  WorkBenchSelectionViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/09/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkBenchSelectionViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var tableview: UITableView!
    @IBOutlet private weak var subtitle: UILabel!

    // MARK: - Variable
    private var data: ActionEntryViewData!
    private var index: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func inject(data: ActionEntryViewData, index: Int) {
        self.data = data
        self.index = index
    }

}

// MARK: - View Controller Event
extension WorkBenchSelectionViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.ActionEntry(segue) {
        case .unwindToWorkObjectSelection:
            if let vc = segue.destination as? WorkObjectSelectionViewController {
                vc.inject(data: data)
            }
        default: break
        }
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension WorkBenchSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.destTray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: WorkBenchSelectionTableViewCell.identifier, for: indexPath)
        guard let cell = _cell as? WorkBenchSelectionTableViewCell else {
            return _cell
        }
        cell.inject(data: data)
        cell.setRow(indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data.works[index].tray = data.destTray[indexPath.row]
        self.perform(segue: StoryboardSegue.ActionEntry.unwindToWorkObjectSelection)
    }
}

// MARK: - Action
extension WorkBenchSelectionViewController {

    @IBAction private func touchUpInsideSubmitButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - Private Function
extension WorkBenchSelectionViewController {

    private func setup() {
        tableview?.tableFooterView = UIView(frame: .zero)
        previewImageView?.image = data.workLibrary?.workbenchImage?.image
        subtitle?.text = L10n.WorkBenchSelection.subtitle
    }
}
