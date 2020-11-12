//
//  CustomButton.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

//@IBDesignable
public class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAttributes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAttributes()
    }

    private func setupAttributes() {
        imageView?.contentMode = .scaleAspectFit
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill
    }

}
