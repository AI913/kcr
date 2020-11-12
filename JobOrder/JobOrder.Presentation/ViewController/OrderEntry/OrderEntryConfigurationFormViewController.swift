//
//  OrderEntryConfigurationFormViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// OrderEntryConfigurationFormViewControllerProtocol
/// @mockable
protocol OrderEntryConfigurationFormViewControllerProtocol: class {
    /// Confirm画面へ遷移
    func transitionToConfirmScreen()
}

class OrderEntryConfigurationFormViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var startConditionValueLabel: UILabel!
    @IBOutlet weak var exitConditionValueLabel: UILabel!
    @IBOutlet weak var numberOfRunsTitleLabel: UILabel!
    @IBOutlet weak var incrementNumberOfRunsBy1Button: UIButton!
    @IBOutlet weak var incrementNumberOfRunsBy5Button: UIButton!
    @IBOutlet weak var incrementNumberOfRunsBy10Button: UIButton!
    @IBOutlet weak var clearNumberOfRunsButton: UIButton!
    @IBOutlet weak var numberOfRunsTextField: UITextField!
    @IBOutlet weak var remarksTextView: UITextView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var scrollView: CustomScrollView!

    // MARK: - Variable
    var viewData: OrderEntryViewData!
    var presenter: OrderEntryConfigurationFormPresenterProtocol!

    func inject(viewData: OrderEntryViewData) {
        self.viewData = viewData
        presenter = OrderEntryBuilder.ConfigurationForm().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeBack()
        numberOfRunsTitleLabel?.attributedText = toRequiredMutableAttributedString(numberOfRunsTitleLabel.text)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
        startConditionValueLabel?.text = presenter?.startCondition
        exitConditionValueLabel?.text = presenter?.exitCondition
        numberOfRunsTextField?.text = presenter?.numberOfRuns
        remarksTextView?.text = presenter?.remarks
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
}

// MARK: - View Controller Event
extension OrderEntryConfigurationFormViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.OrderEntry(segue) {
        case .showConfirm:
            guard let data = presenter?.data else { return }
            (segue.destination as! OrderEntryConfirmViewController).inject(viewData: data)
        default: break
        }
    }
}

// MARK: - View Controller Event
extension OrderEntryConfigurationFormViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Implement UITextViewDelegate
extension OrderEntryConfigurationFormViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        presenter?.remarks = textView.text
    }
}

// MARK: - Action
extension OrderEntryConfigurationFormViewController {

    @IBAction private func editingChangedNumberOfRunsTextField(_ sender: UITextField) {
        presenter?.numberOfRuns = sender.text
    }

    @IBAction private func didEndOnExitNumberOfRunsTextField(_ sender: UITextField) {
        presenter?.numberOfRuns = sender.text
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }

    @IBAction private func touchUpInsideIncrementNumberOfRunsButton(_ sender: UIButton) {
        presenter?.tapIncrementNumberOfRunsButton(num: sender.tag)
        numberOfRunsTextField?.text = presenter?.numberOfRuns
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }

    @IBAction private func touchUpInsideClearNumberOfRunsButton(_ sender: UIButton) {
        presenter?.tapClearNumberOfRunsButton()
        numberOfRunsTextField?.text = presenter?.numberOfRuns
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }

    @IBAction private func touchUpInsideContinueButton(_ sender: UIButton) {
        presenter?.tapContinueButton()
    }
}

// MARK: - Protocol Function
extension OrderEntryConfigurationFormViewController: OrderEntryConfigurationFormViewControllerProtocol {

    func transitionToConfirmScreen() {
        self.perform(segue: StoryboardSegue.OrderEntry.showConfirm)
    }
}

// MARK: - Notification
extension OrderEntryConfigurationFormViewController {

    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        var keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
    }
}
