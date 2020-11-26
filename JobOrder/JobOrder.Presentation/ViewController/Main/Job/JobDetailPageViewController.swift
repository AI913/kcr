//
//  JobDetailPageViewController.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobDetailPageViewController: UIPageViewController {

    // MARK: - Variable
    private var controllers: [JobDetailContainerViewController] = [
        StoryboardScene.Main.jobDetailWork.instantiate(),
        StoryboardScene.Main.jobDetailFlow.instantiate(),
        StoryboardScene.Main.jobDetailRemarks.instantiate()
    ]

    weak var _delegate: JobDetailViewControllerProtocol?
    private var nowIndex: Int = 0

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self

        setViewControllers([controllers[nowIndex]], direction: .forward, animated: false, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        controllers.forEach {
            $0.initialHeight = self.view.frame.height
        }
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        // 各ページのサイズに合わせる
        if container.isEqual(controllers[nowIndex]) {
            preferredContentSize.height = container.preferredContentSize.height
        }
    }

    func inject(viewData: MainViewData.Job) {

        controllers.forEach {
            $0.inject(viewData: viewData)
        }
    }

    func changePage(index: Int) {

        setViewControllers([controllers[index]], direction: .forward, animated: false, completion: { finished in
            self.nowIndex = index
            self.preferredContentSize.height = self.controllers[self.nowIndex].preferredContentSize.height
        })
    }

}

extension JobDetailPageViewController: UIPageViewControllerDelegate {

    // ジェスチャーによる遷移が始まる場合に呼ばれる
    // willTransitionTo.firstを見れば、次の遷移先のページのインスタンスを見ることができる
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {

        if let vc = pendingViewControllers.first as? JobDetailContainerViewController,
           let index = controllers.firstIndex(of: vc) {
            _delegate?.pageChanged(index: index)
            self.preferredContentSize.height = vc.preferredContentSize.height
        }
    }

    // ジェスチャーによる遷移が終わった場合に呼ばれる
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        if completed, let vc = pageViewController.viewControllers?[0] {
            self.preferredContentSize.height = vc.preferredContentSize.height
        } else if let vc = previousViewControllers.first as? JobDetailContainerViewController,
                  let index = controllers.firstIndex(of: vc) {
            _delegate?.pageChanged(index: index)
        }
    }
}

extension JobDetailPageViewController: UIPageViewControllerDataSource {

    /// 右にスワイプ（戻る）した場合のメソッド
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController as! JobDetailContainerViewController),
           index > 0 {
            nowIndex = index - 1
            return controllers[nowIndex]
        } else {
            return nil
        }
    }

    /// 左にスワイプ（進む）した場合のメソッド
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController as! JobDetailContainerViewController),
           index < controllers.count - 1 {
            nowIndex = index + 1
            return controllers[nowIndex]
        } else {
            return nil
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }
}
