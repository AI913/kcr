//
//  RobotDetailPageViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/09/15.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class RobotDetailPageViewController: UIPageViewController {

    // MARK: - Variable
    private var controllers: [RobotDetailContainerViewController] = [
        StoryboardScene.Main.robotDetailWork.instantiate(),
        StoryboardScene.Main.robotDetailSystem.instantiate(),
        StoryboardScene.Main.robotDetailRemarks.instantiate()
    ]

    weak var _delegate: RobotDetailViewControllerProtocol?
    private var nowIndex: Int = 0

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self

        setViewControllers([controllers[0]], direction: .forward, animated: false, completion: nil)
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

    func inject(viewData: MainViewData.Robot) {

        controllers.forEach {
            $0.inject(viewData: viewData)
        }
    }

    func changePage(index: Int) {

        setViewControllers([controllers[index]], direction: .forward, animated: false, completion: { finished in
            self.nowIndex = index
            self.preferredContentSize.height = self.controllers[index].preferredContentSize.height
        })
    }
}

extension RobotDetailPageViewController: UIPageViewControllerDelegate {

    // ジェスチャーによる遷移が始まる場合に呼ばれる
    // willTransitionTo.firstを見れば、次の遷移先のページのインスタンスを見ることができる
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {

        if let vc = pendingViewControllers.first as? RobotDetailContainerViewController,
           let index = controllers.firstIndex(of: vc) {
            _delegate?.pageChanged(index: index)
            self.preferredContentSize.height = max(self.preferredContentSize.height, vc.preferredContentSize.height)
        }
    }

    // ジェスチャーによる遷移が終わった場合に呼ばれる
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        if completed, let vc = pageViewController.viewControllers?[0] as? RobotDetailContainerViewController,
           let index = controllers.firstIndex(of: vc) {
            nowIndex = index
            self.preferredContentSize.height = vc.preferredContentSize.height
        } else if let vc = previousViewControllers.first as? RobotDetailContainerViewController,
                  let index = controllers.firstIndex(of: vc) {
            _delegate?.pageChanged(index: index)
        }
    }
}

extension RobotDetailPageViewController: UIPageViewControllerDataSource {

    /// 右にスワイプ（戻る）した場合のメソッド
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController as! RobotDetailContainerViewController),
           index > 0 {
            return controllers[index - 1]
        } else {
            return nil
        }
    }

    /// 左にスワイプ（進む）した場合のメソッド
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController as! RobotDetailContainerViewController),
           index < controllers.count - 1 {
            return controllers[index + 1]
        } else {
            return nil
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }
}
