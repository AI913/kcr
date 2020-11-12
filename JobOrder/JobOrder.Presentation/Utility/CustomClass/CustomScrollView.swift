//
//  CustomScrollView.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/05/21.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

public class CustomScrollView: UIScrollView {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
    }
}
