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
protocol JobEntrySearchViewControllerProtocol: class {
    /// AILibrary画面へ遷移
    func transitionToAILibrary()
    /// テーブルを更新
    func reloadTable()
}


class JobEntrySearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!

    //SearchBarインスタンス
    private var mySearchBar: UISearchBar!

    //コレクションビュー
    var myCollectionView: UICollectionView!

    //コレクションビューに表示するベースとなる配列
    //ファイル名と製品名
    var array: Array<Array<String>> = [["battery", "充電式乾電池"], ["earphone", "イヤフォン"], ["hdmi", "HDMIケーブル"], ["huto", "封筒"], ["keyborad", "キーボード"], ["moouse", "マウス"], ["tissue", "テッシュ"], ["toiletpaper", "トイレペーパー"], ["keyborad", "キーボード"], ["keyborad", "キーボード"], ["keyborad", "キーボード"]]

    //検索された配列
    var searchedArray: Array<Array<String>>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        searchedArray = array

        //サイズを取得
        let viewWidth: CGFloat = 284
        let viewHeight: CGFloat = 760
        //        let viewWidth = self.view.frame.width
        //        let viewHeight = self.view.frame.height
        let collectionFrame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        let searchBarHeight: CGFloat = 44

        // MARK: - CollectionView関連
        // CollectionViewのレイアウトを生成.
        let layout = UICollectionViewFlowLayout()

        // Cell一つ一つの大きさ.
        layout.itemSize = CGSize(width: viewWidth / 2, height: viewWidth / 1.5)

        // セルのマージン.
        layout.sectionInset = UIEdgeInsets.zero
        //layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16)
        //セルの横方向のマージン
        layout.minimumInteritemSpacing = 0.0

        //セルの縦方向のマージン
        layout.minimumLineSpacing = 0.0

        // セクション毎のヘッダーサイズ.
        //サーチバー大きさ
        layout.headerReferenceSize = CGSize(width: viewWidth, height: searchBarHeight)

        // CollectionViewを生成.
        myCollectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)

        // Cellに使われるクラスを登録.
        myCollectionView.register(JobEntryActionLibraryViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(JobEntryActionLibraryViewCell.self))

        //デリゲートとデータソースを設定
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .white

        //サーチバーの高さだけ初期位置を下げる
        myCollectionView.contentOffset = CGPoint(x: 0, y: searchBarHeight)
        self.view.addSubview(myCollectionView)

        // MARK: - SearchBar関連
        //SearchBarの作成
        mySearchBar = UISearchBar()
        //デリゲートを設定
        mySearchBar.delegate = self
        //大きさの指定
        mySearchBar.frame = CGRect(x: 0, y: 0, width: viewWidth, height: 44)
        //キャンセルボタンの追加
        mySearchBar.showsCancelButton = false
        self.myCollectionView.addSubview(mySearchBar)
    }

    // MARK: - 渡された文字列を含む要素を検索し、テーブルビューを再表示する
    func searchItems(searchText: String) {

        //要素を検索する
        if searchText != "" {
            searchedArray = array.filter { myItem in
                return (myItem[1]).contains(searchText)
            } as Array<Array<String>>

        } else {
            //渡された文字列が空の場合は全てを表示
            searchedArray = array
        }
        //再読み込みする
        myCollectionView.reloadData()
    }

    // MARK: - CollectionView Delegate Methods
    //Cellが選択された際に呼び出される
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
    }

    //Cellの総数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedArray.count
    }

    //Cellに値を設定する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: JobEntryActionLibraryViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(JobEntryActionLibraryViewCell.self), for: indexPath) as! JobEntryActionLibraryViewCell
        cell.thumbnailImageView?.image = UIImage(named: searchedArray[indexPath.row][0])
        cell.textLabel?.text = searchedArray[indexPath.row][1]
        return cell
    }

    // MARK: - SearchBarのデリゲードメソッドたち
    // MARK: テキストが変更される毎に呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //検索する
        searchItems(searchText: searchText)
    }
    //
    // MARK: キャンセルボタンが押されると呼ばれる
    //    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    //
    //        mySearchBar.text = ""
    //        self.view.endEditing(true)
    //        searchedArray = array
    //
    //        //コレクションビューを再読み込みする
    //        myCollectionView.reloadData()
    //    }
    //
    // MARK: Searchボタンが押されると呼ばれる
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //
    //        self.view.endEditing(true)
    //        //検索する
    //        searchItems(searchText: mySearchBar.text! as String)
    //    }
}


//extension JobEntrySearchViewController: UICollectionViewController {
//
//    // MARK: - Variable
//    var presenter: RobotListPresenterProtocol!
//    private let searchController = UISearchController()
//
//    // MARK: - Initializer
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        presenter = MainBuilder.RobotList().build(vc: self)
//    }
//
//    // MARK: - Override function (view controller lifecycle)
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.searchController.searchResultsUpdater = self
//        self.searchController.searchBar.placeholder = L10n.keyword
//        self.searchController.obscuresBackgroundDuringPresentation = false
//        self.navigationItem.searchController = self.searchController
//        self.navigationItem.hidesSearchBarWhenScrolling = false
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? false
//        super.viewWillAppear(animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
//}
//
//// MARK: - View Controller Event
//extension JobEntrySearchViewController {
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch StoryboardSegue.Main(segue) {
//        case .showRobotDetail:
//            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
//            let vc = (segue.destination as! UINavigationController).topViewController as! RobotDetailViewController
//            vc.inject(viewData: MainViewData.Robot(id: presenter?.id(indexPath.row)))
//            vc.navigationItem.leftItemsSupplementBackButton = true
//        default: break
//        }
//    }
//    //}
//    //
//    // MARK: - Implement UITableViewDataSource, UITableViewDelegate
//    //extension RobotListViewController {
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        presenter?.numberOfRowsInSection ?? 0
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let _cell = tableView.dequeueReusableCell(withIdentifier: RobotListViewCell.identifier, for: indexPath)
//        guard let cell = _cell as? RobotListViewCell else {
//            return _cell
//        }
//        cell.inject(presenter: presenter)
//        cell.setRow(indexPath)
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        presenter?.selectRow(index: indexPath.row)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
//
//// MARK: - Implement UISearchResultsUpdating
//extension JobEntrySearchViewController: UISearchResultsUpdating {
//
//    func updateSearchResults(for searchController: UISearchController) {
//        presenter?.filterAndSort(keyword: searchController.searchBar.text, keywordChanged: true)
//    }
//}
//
//// MARK: - Interface Function
//extension JobEntrySearchViewController: JobEntrySearchViewControllerProtocol {
//
//    func transitionToRobotDetail() {
//        self.perform(segue: StoryboardSegue.Main.showRobotDetail)
//    }
//
//    func reloadTable() {
//        self.tableView?.reloadData()
//    }
//}
