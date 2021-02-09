//
//  JobEntryActionLibraryViewCell.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/02.
//

//import UIKit
//
//class JobEntryActionLibraryViewCell: UICollectionViewCell {
//
//    var thumbnailImageView: UIImageView?
//    var nameLabel: UILabel?
//    var versionLabel: UILabel?
//
//    // MARK: - Constant
//    static let identifier: String = "JobEntryActionLibraryViewCell"
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        let width: CGFloat = self.frame.width
//        let height: CGFloat = self.frame.height
//        let margin: CGFloat = 8
//
//        self.backgroundColor = .white
//
//        thumbnailImageView = UIImageView()
//        thumbnailImageView?.image = UIImage(named: "snorlax")
//        thumbnailImageView?.frame = CGRect(x: margin, y: margin, width: width - margin * 2, height: height * 0.7 - margin)
//        self.contentView.addSubview(thumbnailImageView!)
//
//        // UILabelを生成.
//        nameLabel = UILabel(frame: CGRect(x: 0, y: height * 0.7, width: frame.width, height: frame.height * 0.2))
//        nameLabel?.textColor = UIColor.gray
//        nameLabel?.textAlignment = NSTextAlignment.center
//        nameLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//        self.contentView.addSubview(nameLabel!)
//
//        // UILabelを生成.
//        versionLabel = UILabel(frame: CGRect(x: 0, y: height * 0.8, width: frame.width, height: frame.height * 0.2))
//        versionLabel?.textColor = UIColor.gray
//        versionLabel?.textAlignment = NSTextAlignment.center
//        versionLabel?.font = UIFont.boldSystemFont(ofSize: 12)
//        self.contentView.addSubview(versionLabel!)
//    }
//}

import UIKit

class JobEntryActionLibraryViewCell: UICollectionViewCell, UICollectionViewCellWithAutoSizing {

    // MARK: - IBOutlet
    @IBOutlet private weak var actionLibraryImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!

    // MARK: - Constant
    static let identifier: String = "JobEntryActionLibraryViewCell"

    // MARK: - Variable
    private var presenter: JobEntrySearchPresenterProtocol!

    func inject(presenter: JobEntrySearchPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Override function (view lifecycle)
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedBackgroundView = UIView(frame: self.bounds)
        selectedBackgroundView.backgroundColor = .secondarySystemFill
        selectedBackgroundView.alpha = self.alpha * 0.5
        self.selectedBackgroundView = selectedBackgroundView
    }

    // MARK: - Override function
    override func layoutSubviews() {
        super.layoutSubviews()
        if let selectedBackgroundView = self.selectedBackgroundView {
            selectedBackgroundView.frame = self.bounds
        }
    }

    func setItem(_ indexPath: IndexPath) {
        nameLabel?.text = toLabelText(presenter?.displayName(indexPath.row))
        versionLabel?.text = toLabelText(presenter?.version(indexPath.row))
    }
}
