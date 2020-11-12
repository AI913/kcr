//
//  WorkBenchEntryViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/09/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkBenchEntryViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var selectedLibraryLabel: UILabel!
    @IBOutlet private weak var tableview: UITableView!
    @IBOutlet private weak var subtitle1: UILabel!
    @IBOutlet private weak var subtitle2: UILabel!
    @IBOutlet private weak var previewImageView: UIImageView!
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
extension WorkBenchEntryViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.ActionEntry(segue) {
        case .toWorkbenchLibrarySelection:
            if let vc = segue.destination as? WorkbenchLibrarySelectionViewController {
                vc.inject(data: data)
            }
        case .toWorkObjectLibrarySelection:
            if let vc = segue.destination as? WorkObjectLibrarySelectionViewController {
                vc.inject(data: data)
            }
        default: break
        }
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension WorkBenchEntryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        35
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = data.workbenchLibrary else { return 0 }
        return ActionEntryViewData.Tray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let _cell = tableView.dequeueReusableCell(withIdentifier: WorkBenchEntryTableViewCell.identifier, for: indexPath)
        guard let cell = _cell as? WorkBenchEntryTableViewCell else {
            return _cell
        }

        cell.inject(data: data)
        cell.setRow(indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)

        data.destTray.removeAll()
        ActionEntryViewData.Tray.allCases.enumerated().forEach {
            if $0.offset >= ActionEntryViewData.Tray.count {
                return
            } else if $0.offset == indexPath.row {
                data.srcTray = $0.element
            } else {
                data.destTray.append($0.element)
            }
        }
        perform(segue: StoryboardSegue.ActionEntry.toWorkObjectLibrarySelection, sender: nil)
    }
}

// MARK: - Action
extension WorkBenchEntryViewController {

    @IBAction private func returnActionForSegue(_ segue: UIStoryboardSegue) {
        setup()
        tableview?.reloadData()
    }
}

// MARK: - Private Function
extension WorkBenchEntryViewController {

    private func setup() {
        tableview?.tableFooterView = UIView(frame: .zero)
        subtitle1?.text = L10n.WorkBenchEntry.subtitle1
        subtitle2?.text = L10n.WorkBenchEntry.subtitle2
        bottomButton?.setTitle(L10n.WorkBenchEntry.bottomButton, for: .normal)
        bottomButton?.isEnabled = tableview?.indexPathForSelectedRow != nil
        let name = data.workbenchLibrary?.name ?? L10n.WorkBenchEntry.notSelected
        selectedLibraryLabel?.text = "\(L10n.WorkBenchEntry.library): \(name)"
        previewImageView?.image = data.workbenchLibrary?.cameraImage.image
    }
}
