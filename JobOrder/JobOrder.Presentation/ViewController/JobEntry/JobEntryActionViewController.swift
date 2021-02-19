//
//  JobEntryActionViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/19.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobEntryActionViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var slideMenuView: UIView!

    var isExpanded: Bool = false

    @IBAction func slideMenuButtonTapped(_ sender: Any) {
        isExpanded = !isExpanded
        showMenu(shouldExpand: isExpanded)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showMenu(shouldExpand: isExpanded)
    }

    func showMenu(shouldExpand: Bool) {
        if shouldExpand {
            // show menu
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .curveEaseInOut,
                animations: { self.slideMenuView.frame.origin.x = 0 },
                completion: nil
            )
        } else {
            // hide menu
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .curveEaseInOut,
                animations: { self.slideMenuView.frame.origin.x = -self.slideMenuView.frame.width },
                completion: nil
            )
        }
    }
}
