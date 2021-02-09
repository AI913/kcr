//
//  JobEntrySearchViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/03.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit
/// JobEntrySearchViewControllerProtocol
/// @mockable
//protocol JobEntrySearchViewControllerProtocol: class {
//    /// AILibrary画面へ遷移
//    func transitionToAILibrary()
//    /// テーブルを更新
//    func reloadTable()
//}
//
//
//class JobEntrySearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
//
//    // MARK: - IBOutlet
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    //SearchBarインスタンス
//    private var mySearchBar: UISearchBar!
//
//    //コレクションビュー
//    var myCollectionView: UICollectionView!
//
//    //コレクションビューに表示するベースとなる配列
//    //ファイル名と製品名
//    var array: Array<Array<String>> = [["battery", "充電式乾電池","Ver.1.0.0"], ["earphone", "イヤフォン","Ver.1.0.1"], ["hdmi", "HDMIケーブル","Ver.1.0.2"], ["huto", "封筒","Ver.1.0.3"], ["keyborad", "キーボード","Ver.1.0.4"], ["moouse", "マウス","Ver.1.0.5"], ["tissue", "テッシュ","Ver.1.0.6"], ["toiletpaper", "トイレペーパー","Ver.1.0.7"], ["keyborad", "キーボード","Ver.1.0.8"], ["keyborad", "キーボード","Ver.1.0.9"], ["keyborad", "キーボード","Ver.1.1.0"], ["keyborad", "キーボード","Ver.1.1.1"], ["keyborad", "キーボード","Ver.1.1.2"], ["keyborad", "キーボード","Ver.1.1.3"]]
//
//    //検索された配列
//    var searchedArray: Array<Array<String>>!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.view.backgroundColor = .white
//
//        searchedArray = array
//
//        //サイズを取得
//        let viewWidth: CGFloat = 284
//        let viewHeight: CGFloat = 760
//        //        let viewWidth = self.view.frame.width
//        //        let viewHeight = self.view.frame.height
//        let collectionFrame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
//        let searchBarHeight: CGFloat = 44
//
//        // MARK: - CollectionView関連
//        // CollectionViewのレイアウトを生成.
//        let layout = UICollectionViewFlowLayout()
//
//        // Cell一つ一つの大きさ.
//        layout.itemSize = CGSize(width: viewWidth / 2, height: viewWidth / 1.5)
//
//        // セルのマージン.
//        layout.sectionInset = UIEdgeInsets.zero
//        //layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16)
//        //セルの横方向のマージン
//        layout.minimumInteritemSpacing = 0.0
//
//        //セルの縦方向のマージン
//        layout.minimumLineSpacing = 0.0
//
//        // セクション毎のヘッダーサイズ.
//        //サーチバー大きさ
//        layout.headerReferenceSize = CGSize(width: viewWidth, height: searchBarHeight)
//
//        // CollectionViewを生成.
//        myCollectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
//
//        // Cellに使われるクラスを登録.
//        myCollectionView.register(JobEntryActionLibraryViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(JobEntryActionLibraryViewCell.self))
//
//        //デリゲートとデータソースを設定
//        myCollectionView.delegate = self
//        myCollectionView.dataSource = self
//        myCollectionView.backgroundColor = .white
//
//        //サーチバーの高さだけ初期位置を下げる
//        myCollectionView.contentOffset = CGPoint(x: 0, y: searchBarHeight)
//        self.view.addSubview(myCollectionView)
//
//        // MARK: - SearchBar関連
//        //SearchBarの作成
//        mySearchBar = UISearchBar()
//        //デリゲートを設定
//        mySearchBar.delegate = self
//        //大きさの指定
//        mySearchBar.frame = CGRect(x: 0, y: 0, width: viewWidth, height: 44)
//        //キャンセルボタンの追加
//        mySearchBar.showsCancelButton = false
//        self.myCollectionView.addSubview(mySearchBar)
//    }
//
//    // MARK: - 渡された文字列を含む要素を検索し、テーブルビューを再表示する
//    func searchItems(searchText: String) {
//
//        //要素を検索する
//        if searchText != "" {
//            searchedArray = array.filter { myItem in
//                return (myItem[1]).contains(searchText)
//            } as Array<Array<String>>
//
//        } else {
//            //渡された文字列が空の場合は全てを表示
//            searchedArray = array
//        }
//        //再読み込みする
//        myCollectionView.reloadData()
//    }
//
//    // MARK: - CollectionView Delegate Methods
//    //Cellが選択された際に呼び出される
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Num: \(indexPath.row)")
//    }
//
//    //Cellの総数を返す
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return searchedArray.count
//    }
//
//    //Cellに値を設定する
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell: JobEntryActionLibraryViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(JobEntryActionLibraryViewCell.self), for: indexPath) as! JobEntryActionLibraryViewCell
//        cell.thumbnailImageView?.image = UIImage(named: searchedArray[indexPath.row][0])
//        cell.nameLabel?.text = searchedArray[indexPath.row][1]
//        cell.versionLabel?.text = searchedArray[indexPath.row][2]
//        return cell
//    }
//
//    // MARK: - SearchBarのデリゲードメソッドたち
//    // MARK: テキストが変更される毎に呼ばれる
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        //検索する
//        searchItems(searchText: searchText)
//    }
//}
protocol JobEntrySearchViewControllerProtocol: class {
    /// RobotSelection画面へ遷移
    func transitionToAILibrarySelectionScreen()
    /// コレクションを更新
    func reloadCollection()
}

class JobEntrySearchViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Variable
    var viewData: JobEntryViewData!
    var presenter: JobEntrySearchPresenterProtocol!
    private var computedCellSize: CGSize?

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Implement UICollectionViewDataSource
extension JobEntrySearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfRowsInSection ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobEntryActionLibraryViewCell.identifier, for: indexPath)
        guard let cell = _cell as? JobEntryActionLibraryViewCell else {
            return _cell
        }
        return cell
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension JobEntrySearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard computedCellSize == nil else {
            return computedCellSize!
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderEntryJobSelectionJobCollectionViewCell.identifier, for: indexPath)
        guard let prototypeCell = cell as? OrderEntryJobSelectionJobCollectionViewCell,
              let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("CollectionView is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 2)
        computedCellSize = cellSize
        return cellSize
    }
}

// MARK: - Protocol Function
extension JobEntrySearchViewController: OrderEntryJobSelectionViewControllerProtocol {

    func transitionToRobotSelectionScreen() {
        self.perform(segue: StoryboardSegue.OrderEntry.showRobotSelection)
    }

    func reloadCollection() {
        collectionView?.reloadData()
    }
}
