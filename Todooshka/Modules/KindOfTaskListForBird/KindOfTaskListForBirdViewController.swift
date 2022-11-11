//
//  KindOfTaskForBirdViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 22.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit

class KindOfTaskListForBirdViewController: TDViewController {
  // MARK: - Properties
  // Rx
  let disposeBag = DisposeBag()
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskListSection>!

  // MVVM
  var viewModel: KindOfTaskListForBirdViewModel!

  // UI
  private var collectionView: UICollectionView!

  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()

  private let alertCancelButton: UIButton = {
    let button = UIButton(type: .system)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text!.withAlphaComponent(0.5), for: .normal)
    return button
  }()

  private let alertOkButton: UIButton = {
    let attrString = NSAttributedString(string: "Ok", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    let button = UIButton(type: .system)
    button.backgroundColor = Style.Buttons.AlertGreenButton.Background
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()

  private let alertWindowView: UIView = {
    let view = UIView()
    view.cornerRadius = 27
    view.backgroundColor = Style.App.background
    return view
  }()

  private let alertTextView: UITextView = {
    let textView = UITextView()
    textView.backgroundColor = .clear
    textView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    textView.isEditable = false
    textView.isSelectable = false
    textView.textContainer.lineBreakMode = .byWordWrapping
    textView.textAlignment = .center
    textView.textColor = Style.App.text
    return textView
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // header
    backButton.isHidden = false
    titleLabel.text = "Типы задач"

    // collection view
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())

    view.addSubview(collectionView)

    // collectionView
    collectionView.register(KindOfTaskListCell.self, forCellWithReuseIdentifier: KindOfTaskListCell.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    collectionView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }

  private func configureAlert() {
    view.addSubview(alertBackgroundView)
    alertBackgroundView.addSubview(alertWindowView)
    alertBackgroundView.addSubview(alertTextView)
    alertWindowView.addSubview(alertCancelButton)
    alertWindowView.addSubview(alertOkButton)

    // alertView
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

    // alertWindowView
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()
    alertWindowView.anchor(
      widthConstant: Sizes.Views.AlertDeleteView.width,
      heightConstant: Sizes.Views.AlertDeleteView.height
    )

    // alertTextViewBackground
    alertTextView.anchor(
      top: alertWindowView.topAnchor,
      left: alertWindowView.leftAnchor,
      right: alertWindowView.rightAnchor,
      topConstant: 4,
      leftConstant: 4,
      rightConstant: 4,
      heightConstant: 75
    )

    // alertOkButton
    alertOkButton.cornerRadius = 15
    alertOkButton.anchorCenterXToSuperview()
    alertOkButton.anchor(
      top: alertTextView.bottomAnchor,
      topConstant: 8,
      widthConstant: Sizes.Buttons.AlertOkButton.width,
      heightConstant: Sizes.Buttons.AlertOkButton.height
    )

    // alertCancelButton
    alertCancelButton.anchorCenterXToSuperview()
    alertCancelButton.anchor(top: alertOkButton.bottomAnchor, topConstant: 10)
  }

  // MARK: - Setup Collection View
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0)
    return section
  }

  // MARK: - Bind To
  func bindViewModel() {
    let input = KindOfTaskListForBirdViewModel.Input(
      // selection
      selection: collectionView.rx.itemSelected.asDriver(),
      // alert
      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver(),
      alertOkButtonClick: alertOkButton.rx.tap.asDriver(),
      // back
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.add.drive(),
      outputs.alertTitleLabel.drive(textViewTextBinder),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.hideAlert.drive(hideAlertBinder),
      outputs.navigateBack.drive(),
      outputs.showAlert.drive(showAlertBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  // MARK: - Binders
  var textViewTextBinder: Binder<String> {
    return Binder(self, binding: { vc, text in
      vc.alertTextView.text = text
      vc.alertTextView.centerVerticalText()
    })
  }

  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertBackgroundView.isHidden = true
    })
  }

  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertBackgroundView.isHidden = false
    })
  }

  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskListSection>(configureCell: { _, collectionView, indexPath, kindOfTask in
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: KindOfTaskListCell.reuseID,
        for: indexPath
      ) as? KindOfTaskListCell else { return UICollectionViewCell() }
      cell.configure(with: kindOfTask, mode: .withRightImage )
      return cell
    })
  }
}

extension UITextView {
  /// Modifies the top content inset to center the text vertically.
  ///
  /// Use KVO on the UITextView contentSize and call this method inside observeValue(forKeyPath:of:change:context:)
  func alignTextVerticallyInContainer() {
    var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
    topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect
    self.contentInset.top = topCorrect
  }
}
