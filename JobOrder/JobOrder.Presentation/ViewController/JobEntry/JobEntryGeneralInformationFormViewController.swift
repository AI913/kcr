//
//  JobEntryGeneralInformationFormViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/12.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobEntryGeneralInformationFormViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var jobNameTitleLabel: UILabel!
    @IBOutlet private weak var jobNameTextField: UITextField!
    @IBOutlet private weak var overviewTitleLabel: UILabel!
    @IBOutlet private weak var overviewTextView: UITextView!
    @IBOutlet private weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var continueButton: UIButton!

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Override function (view controller event)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Implement UITextFieldDelegate
extension JobEntryGeneralInformationFormViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let updatedText = self.updatedText(textField.text, range: range, replacementString: string)
        self.continueButton.isEnabled = updatedText != nil
        return true
    }

    private func updatedText(_ text: String?, range: NSRange, replacementString: String) -> String? {

        guard let unwrappedText = text else {
            return text
        }

        guard let textRange = Range(range, in: unwrappedText) else {
            return text
        }

        return unwrappedText.replacingCharacters(in: textRange, with: replacementString)
    }
}

// MARK: - Implement UITextViewDelegate
extension JobEntryGeneralInformationFormViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
    }
}

// MARK: - Action
extension JobEntryGeneralInformationFormViewController {

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @IBAction private func didEndOnExitJobNameTextField(_ sender: UITextField) {
        self.overviewTextView.becomeFirstResponder()
    }

    @IBAction private func touchUpInsideContinueButton(_ sender: UIButton) {
        let vc = StoryboardScene.ActionEntry.initialScene.instantiate()
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Private Function
extension JobEntryGeneralInformationFormViewController {

    private func setup() {
        navigationItem.leftBarButtonItem?.title = L10n.cancel
        navigationItem.title = L10n.JobEntryGeneralInformationForm.title
        subtitle?.text = L10n.JobEntryGeneralInformationForm.subtitle
        jobNameTitleLabel?.text = L10n.JobEntryGeneralInformationForm.jobName
        jobNameTitleLabel?.attributedText = self.toRequiredMutableAttributedString(jobNameTitleLabel.text)
        overviewTitleLabel?.text = L10n.JobEntryGeneralInformationForm.remarks
        continueButton?.setTitle(L10n.JobEntryGeneralInformationForm.bottomButton, for: .normal)
    }
}
