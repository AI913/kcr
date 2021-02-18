//
//  JobEntryGeneralInfoViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/12.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobEntryGeneralInfoViewControllerProtocol
/// @mockable
protocol JobEntryGeneralInfoViewControllerProtocol: class {
    /// ConfigurationForm画面へ遷移
    func transitionToActionScreen()
    /// コレクションを更新
    func reloadCollection()
}

class JobEntryGeneralInfoViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet var robotCollection: UICollectionView!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var jobNameTitleLabel: UILabel!
    @IBOutlet weak var jobNameTextField: UITextField!
    @IBOutlet weak var overviewTitleLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var continueButton: UIButton!

    // MARK: - Variable
    var presenter: JobEntryGeneralInfoPresenterProtocol!
    private var computedCellSize: CGSize?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = JobEntryBuilder.GeneralInfo().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        robotCollection?.allowsSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }

    // MARK: - Override function (view controller event)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Implement UITextFieldDelegate
extension JobEntryGeneralInfoViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let updatedText = self.updatedText(textField.text, range: range, replacementString: string)
            self.continueButton.isEnabled = presenter?.isEnabledContinueButton ?? true && updatedText != ""
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

// MARK: - Action
extension JobEntryGeneralInfoViewController {

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @IBAction private func didEndOnExitJobNameTextField(_ sender: UITextField) {
        self.overviewTextView.becomeFirstResponder()
    }

    @IBAction private func touchUpInsideContinueButton(_ sender: UIButton) {
        //                let vc = StoryboardScene.ActionEntry.initialScene.instantiate()
        //                self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Private Function
extension JobEntryGeneralInfoViewController {

    private func setup() {
        navigationItem.leftBarButtonItem?.title = L10n.cancel
        navigationItem.title = L10n.JobEntryGeneralInformationForm.title
        subtitle?.text = L10n.JobEntryGeneralInformationForm.subtitle
        jobNameTitleLabel?.attributedText = self.toRequiredMutableAttributedString(jobNameTitleLabel.text)
        continueButton?.setTitle(L10n.JobEntryGeneralInformationForm.bottomButton, for: .normal)
    }
}

// MARK: - Implement UICollectionViewDataSource
extension JobEntryGeneralInfoViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfItemsInSection ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobEntryRobotSelectionRobotCollectionViewCell.identifier, for: indexPath)
        guard let cell = _cell as? JobEntryRobotSelectionRobotCollectionViewCell else {
            return _cell
        }

        cell.inject(presenter: presenter)
        cell.setItem(indexPath)
        if let presenter = presenter, presenter.isSelected(indexPath: indexPath) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        return cell
    }
}

// MARK: - Implement UICollectionViewDelegate
extension JobEntryGeneralInfoViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.selectItem(indexPath: indexPath)
        continueButton?.isEnabled = jobNameTextField.text != ""
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension JobEntryGeneralInfoViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard self.computedCellSize == nil else {
            return self.computedCellSize!
        }
        
        print(indexPath)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobEntryRobotSelectionRobotCollectionViewCell.identifier, for: indexPath)

        guard let prototypeCell = cell as? JobEntryRobotSelectionRobotCollectionViewCell,
              let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("CollectionViewCell is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 2)
        self.computedCellSize = cellSize
        return cellSize
    }
}

// MARK: - Protocol Function
extension JobEntryGeneralInfoViewController: JobEntryGeneralInfoViewControllerProtocol {

    func transitionToActionScreen() {
        self.perform(segue: StoryboardSegue.JobEntry.showAction)
    }

    func reloadCollection() {
        robotCollection?.reloadData()
    }
}
