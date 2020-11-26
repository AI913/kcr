//
//  JobDetailWorkTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobDetailWorkTableViewCell: UITableViewCell {

    // MARK: - Variable
    var identifier = ""
    var presenter: JobDetailWorkPresenterProtocol!
    var dataset: JobDetailWorkPresenter.Dataset!

    func inject(presenter: JobDetailWorkPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Function
    func setRow(_ indexPath: IndexPath) {}

}
