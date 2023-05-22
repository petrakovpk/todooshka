//
//  KindOfTaskViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.09.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources

class KindViewController: TDViewController {
  public var viewModel: KindViewModel!
  
  private let disposeBag = DisposeBag()

  // MARK: - UI Elements
  private let taskTypeImageContainerView: UIView = {
    let view = UIView()
    view.cornerRadius = 16
    view.layer.borderWidth = 1
    view.layer.borderColor = Style.Cells.Kind.Border?.cgColor
    view.backgroundColor = Style.Cells.Kind.UnselectedBackground
    return view
  }()

  private let taskTypeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .clear
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private let kindTextLabel: UILabel = {
    let label = UILabel()
    label.text = "Название типа задач"
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let kindTextField = TDTaskTextField(placeholder: "Введите название типа")

  private let kindTextLengthLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.textColor = UIColor(red: 0.188, green: 0.2, blue: 0.325, alpha: 1)
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()

  private let colorLabel: UILabel = {
    let label = UILabel()
    label.text = "Цвет:"
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    return label
  }()

  private let colorCollectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: Sizes.Cells.ColorCell.width, height: Sizes.Cells.ColorCell.height)
    layout.minimumLineSpacing = 11
    return layout
  }()

  private let imageLabel: UILabel = {
    let label = UILabel()
    label.text = "Значок:"
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    return label
  }()

  private var iconCollectionView: UICollectionView!
  private var colorCollecionView: UICollectionView!
  private var iconDataSource: RxCollectionViewSectionedAnimatedDataSource<KindIconSection>!
  private var colorDataSource: RxCollectionViewSectionedAnimatedDataSource<KindColorSection>!
  
  private let iconCollectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: Sizes.Cells.IconCell.width, height: Sizes.Cells.IconCell.height)
    layout.minimumLineSpacing = 8
    return layout
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    colorCollecionView = UICollectionView(frame: .zero, collectionViewLayout: colorCollectionViewLayout)
    iconCollectionView = UICollectionView(frame: .zero, collectionViewLayout: iconCollectionViewLayout)
    
    backButton.isHidden = false
    headerSaveButton.isHidden = false
    
    view.backgroundColor = Style.App.background
    
    hideKeyboardWhenTappedAround()
    
    view.addSubviews([
      kindTextLabel,
      kindTextField,
      kindTextLengthLabel,
      colorLabel,
      colorCollecionView,
      imageLabel,
      iconCollectionView,
      taskTypeImageContainerView
    ])

    taskTypeImageContainerView.addSubviews([
      taskTypeImageView
    ])

    taskTypeImageContainerView.anchorCenterXToSuperview()
    taskTypeImageContainerView.anchor(
      top: headerView.bottomAnchor,
      topConstant: 16,
      widthConstant: Sizes.Views.KindsOfTaskContainerView.width,
      heightConstant: Sizes.Views.KindsOfTaskContainerView.height
    )

    taskTypeImageView.anchorCenterXToSuperview()
    taskTypeImageView.anchorCenterYToSuperview()

    kindTextLabel.anchor(
      top: taskTypeImageContainerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 21,
      leftConstant: 16,
      rightConstant: 16)

    kindTextField.returnKeyType = .done
    kindTextField.anchor(
      top: kindTextLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant)

    kindTextLengthLabel.anchor(
      top: kindTextLabel.topAnchor,
      bottom: kindTextLabel.bottomAnchor,
      right: view.rightAnchor,
      rightConstant: 16)

    colorLabel.anchor(
      top: kindTextField.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16)

    colorCollecionView.register(KindColorCell.self, forCellWithReuseIdentifier: KindColorCell.reuseID)
    colorCollecionView.clipsToBounds = false
    colorCollecionView.isScrollEnabled = false
    colorCollecionView.backgroundColor = UIColor.clear
    colorCollecionView.anchor(
      top: colorLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 14,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: (48 + 48 + 10).adjustByWidth
    )

    imageLabel.anchor(
      top: colorCollecionView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16)

    iconCollectionView.register(KindIconCell.self, forCellWithReuseIdentifier: KindIconCell.reuseID)
    iconCollectionView.clipsToBounds = false
    iconCollectionView.isScrollEnabled = false
    iconCollectionView.backgroundColor = UIColor.clear
    iconCollectionView.anchor(
      top: imageLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: (62 * 4 + 8 * 3).adjustByWidth
    )
  }

  // MARK: - Color CollectionView
  func configureDataSource() {
    colorCollecionView.dataSource = nil
    colorDataSource = RxCollectionViewSectionedAnimatedDataSource<KindColorSection>(
      configureCell: {_, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: KindColorCell.reuseID,
          for: indexPath
        ) as? KindColorCell else { return UICollectionViewCell() }
        cell.configure(with: item)
        return cell
      })

    iconCollectionView.dataSource = nil
    iconDataSource = RxCollectionViewSectionedAnimatedDataSource<KindIconSection>(
      configureCell: {_, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: KindIconCell.reuseID,
          for: indexPath
        ) as? KindIconCell else { return UICollectionViewCell()}
        cell.configure(with: item)
        return cell
      })
  }

  // MARK: - Bind TO
  func bindViewModel() {
    // init
    kindTextField.insertText(viewModel.kind.value.text)
    
    let input = KindViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      saveButtonClickTrigger: headerSaveButton.rx.tap.asDriver(),
      // text
      text: kindTextField.rx.text.orEmpty.asDriver(),
      // color
      kindColorSelected: colorCollecionView.rx.itemSelected.asDriver(),
      // icon
      kindIconSelected: iconCollectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)
    [
      // header
      outputs.navigateBack.drive(),
      // text
      outputs.kindText.drive(kindTextField.rx.text),
      outputs.kindTextLength.drive(kindTextLengthLabel.rx.text),
      // color
      outputs.kindColorSections.drive(colorCollecionView.rx.items(dataSource: colorDataSource)),
      // icon
      outputs.kindIconSections.drive(iconCollectionView.rx.items(dataSource: iconDataSource)),
      // kind chagne and save
      outputs.kindChange.drive(),
      outputs.kindSave.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
}
