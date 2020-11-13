//
//  UICollectionViewFlowLayout.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

// https://qiita.com/imk2o/items/f09a39ba61933da282cf

import UIKit

public protocol UICollectionViewCellWithAutoSizing: class {
}

extension UICollectionViewCellWithAutoSizing where Self: UICollectionViewCell {
    /// 原型ビューに準拠した大きさを求める。
    /// self自身のレイアウトを変更するため、表示に利用していないビューから呼び出すこと。
    ///
    /// - Parameters:
    ///   - flowLayout: フローレイアウト
    ///   - nColumns: 列数
    /// - Returns: 大きさを返す
    public func propotionalScaledSize(
        for flowLayout: UICollectionViewFlowLayout,
        numberOfColumns nColumns: Int
    ) -> CGSize {
        // 幅は必ず指定のwidthに合わせ、高さはLayout Constraintに則った値とするサイズを求める
        let width = flowLayout.preferredItemWidth(forNumberOfColumns: nColumns)
        self.bounds.size = CGSize(width: width, height: 100)
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.layoutIfNeeded()

        return self.systemLayoutSizeFitting(
            UIView.layoutFittingExpandedSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultHigh
        )
    }
}

private extension UICollectionViewFlowLayout {
    /// 列数に対するアイテムの推奨サイズ(幅)を求める。
    ///
    /// - Parameter nColumns: 列数
    /// - Returns: 幅を返す
    func preferredItemWidth(forNumberOfColumns nColumns: Int) -> CGFloat {

        guard nColumns > 0 else {
            return 0
        }

        guard let collectionView = self.collectionView else {
            fatalError("CollectionView is not found.")
        }

        let collectionViewWidth = collectionView.bounds.width
        let inset = self.sectionInset
        let spacing = self.minimumInteritemSpacing

        // コレクションビューの幅から、各余白を除いた幅を均等に割る
        return ((collectionViewWidth - (inset.left + inset.right + spacing * CGFloat(nColumns - 1))) / CGFloat(nColumns)) - 1
    }
}
