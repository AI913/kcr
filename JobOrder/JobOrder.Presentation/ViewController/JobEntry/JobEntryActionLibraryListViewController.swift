//
//  JobEntryActionLibraryListViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/02.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobEntryActionLibraryListViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        let menuPos = self.menuView.layer.position
        self.menuView.layer.position.x = -self.menuView.frame.width
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { self.menuView.layer.position.x = menuPos.x }, completion: { bool in })
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { self.menuView.layer.position.x = -self.menuView.frame.width }, completion: { bool in self.dismiss(animated: true, completion: nil) })
            }
        }
    }
}
