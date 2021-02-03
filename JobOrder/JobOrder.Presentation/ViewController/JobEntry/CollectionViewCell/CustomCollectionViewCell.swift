//
//  CustomCollectionViewCell.swift
//  CollectionViewSample2
//
//  Created by Frontarc on 2021/02/02.
//

import UIKit

class CustumCollectionViewCell: UICollectionViewCell {

    var thumbnailImageView: UIImageView?
    var textLabel: UILabel?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let width: CGFloat = self.frame.width
        let height: CGFloat = self.frame.height
        let margin: CGFloat = 8
        
        self.backgroundColor = .white

        thumbnailImageView = UIImageView()
        thumbnailImageView?.image = UIImage(named: "snorlax")
        thumbnailImageView?.frame = CGRect(x: margin, y: margin, width: width - margin * 2, height: height * 0.8 - margin)
        self.contentView.addSubview(thumbnailImageView!)

        // UILabelを生成.
        textLabel = UILabel(frame: CGRect(x: 0, y: height * 0.8, width: frame.width, height: frame.height * 0.2))
        textLabel?.textColor = UIColor.gray
        textLabel?.textAlignment = NSTextAlignment.center
        textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        self.contentView.addSubview(textLabel!)
    }
}
