//
//  JobEntryActionViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/09/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobListViewControllerProtocol
/// @mockable
protocol JobEntryActionFlowViewControllerProtocol: class {
    /// JobDetail画面へ遷移
    func transitionToActionEntryConfiguration()
}

class JobEntryActionFlowViewController: UIViewController {
    
    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
        let navigationController = StoryboardScene.ActionEntry.actionEntryFormNavi.instantiate()
        self.present(navigationController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        self.perform(segue: StoryboardSegue.JobEntry.showConfirm)
    }
}
