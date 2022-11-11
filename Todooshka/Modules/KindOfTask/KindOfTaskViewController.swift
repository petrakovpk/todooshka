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

class KindOfTaskViewController: TDViewController {
  // MARK: - Properties
  var viewModel: KindOfTaskViewModel!
  let disposeBag = DisposeBag()

  private var dataSourceColor: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskColorSection>!
  private var dataSourceIcon: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskIconSection>!

  // MARK: - UI Elements
  private let taskTypeImageContainerView: UIView = {
    let view = UIView()
    view.cornerRadius = 16
    view.layer.borderWidth = 1
    view.layer.borderColor = Style.Cells.KindOfTask.Border?.cgColor
    view.backgroundColor = Style.Cells.KindOfTask.UnselectedBackground
    return view
  }()

  private let taskTypeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .clear
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private let textLabel = UILabel()
  private let textField = TDTaskTextField(placeholder: "Введите название типа")

  private let textLenLabel: UILabel = {
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

  private var collectionViewColor: UICollectionView!
  private let collectionViewColorLayout: UICollectionViewFlowLayout = {
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

  private var collectionViewIcon: UICollectionView!
  private let collectionViewIconLayout: UICollectionViewFlowLayout = {
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
    backButton.isHidden = false
    
    collectionViewColor = UICollectionView(frame: .zero, collectionViewLayout: collectionViewColorLayout)
    collectionViewIcon = UICollectionView(frame: .zero, collectionViewLayout: collectionViewIconLayout)

    // adding 
    view.addSubview(textLabel)
    view.addSubview(textField)
    view.addSubview(textLenLabel)
    view.addSubview(colorLabel)
    view.addSubview(collectionViewColor)
    view.addSubview(imageLabel)
    view.addSubview(collectionViewIcon)
    view.addSubview(taskTypeImageContainerView)
    taskTypeImageContainerView.addSubview(taskTypeImageView)

    // view
    view.backgroundColor = Style.App.background

    // keyboard
    hideKeyboardWhenTappedAround()

    // saveButton
    saveButton.isHidden = false

    // taskTypeImageContainerView
    taskTypeImageContainerView.anchorCenterXToSuperview()
    taskTypeImageContainerView.anchor(
      top: headerView.bottomAnchor,
      topConstant: 16,
      widthConstant: Sizes.Views.KindsOfTaskContainerView.width,
      heightConstant: Sizes.Views.KindsOfTaskContainerView.height
    )

    // taskTypeImageView
    taskTypeImageView.anchorCenterXToSuperview()
    taskTypeImageView.anchorCenterYToSuperview()

    // textLabel
    textLabel.text = "Название типа задач"
    textLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    textLabel.textAlignment = .left
    textLabel.anchor(top: taskTypeImageContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 21, leftConstant: 16, rightConstant: 16)

    // nameTextField
    textField.returnKeyType = .done
    textField.anchor(
      top: textLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16, rightConstant: 16, heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant)

    // nameSymbolsCountLabel
    textLenLabel.anchor(top: textLabel.topAnchor, bottom: textLabel.bottomAnchor, right: view.rightAnchor, rightConstant: 16)

    // colorLabel
    colorLabel.anchor(top: textField.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16)

    // colorCollectionView
    collectionViewColor.register(KindOfTaskColorCell.self, forCellWithReuseIdentifier: KindOfTaskColorCell.reuseID)
    collectionViewColor.clipsToBounds = false
    collectionViewColor.isScrollEnabled = false
    collectionViewColor.backgroundColor = UIColor.clear
    collectionViewColor.anchor(
      top: colorLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 14,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: (48 + 48 + 10).adjustByWidth
    )

    // imageLabel
    imageLabel.anchor(top: collectionViewColor.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16)

    // imageCollectionView
    collectionViewIcon.register(KindOfTaskIconCell.self, forCellWithReuseIdentifier: KindOfTaskIconCell.reuseID)
    collectionViewIcon.clipsToBounds = false
    collectionViewIcon.isScrollEnabled = false
    collectionViewIcon.backgroundColor = UIColor.clear
    collectionViewIcon.anchor(
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
    collectionViewColor.dataSource = nil
    dataSourceColor = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskColorSection>(
      configureCell: {_, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: KindOfTaskColorCell.reuseID,
          for: indexPath
        ) as? KindOfTaskColorCell else { return UICollectionViewCell() }
        cell.configure(with: item)
        return cell
      })

    collectionViewIcon.dataSource = nil
    dataSourceIcon = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskIconSection>(
      configureCell: {_, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: KindOfTaskIconCell.reuseID,
          for: indexPath
        ) as? KindOfTaskIconCell else { return UICollectionViewCell()}
        cell.configure(with: item)
        return cell
      })
  }

  // MARK: - Bind TO
  func bindViewModel() {
    let input = KindOfTaskViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      saveButtonClickTrigger: saveButton.rx.tap.asDriver(),
      selectionColor: collectionViewColor.rx.itemSelected.asDriver(),
      selectionIcon: collectionViewIcon.rx.itemSelected.asDriver(),
      text: textField.rx.text.orEmpty.asDriver()
    )

    let output = viewModel.transform(input: input)

    [
      output.navigateBack.drive(),
      output.dataSourceColor.drive(collectionViewColor.rx.items(dataSource: dataSourceColor)),
      output.dataSourceIcon.drive(collectionViewIcon.rx.items(dataSource: dataSourceIcon)),
      output.text.drive(textField.rx.text),
      output.save.drive(),
      output.selectIcon.drive(taskTypeImageView.rx.image),
      output.selectColor.drive(taskTypeImageView.rx.tintColor),
      output.textLen.drive(textLenLabel.rx.text)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
}
