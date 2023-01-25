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

  public var viewModel: KindOfTaskViewModel!
  
  private let disposeBag = DisposeBag()

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

  private let textLabel: UILabel = {
    let label = UILabel()
    label.text = "Название типа задач"
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
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

 
  private var colorCollecionView: UICollectionView!
  private var colorDataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskColorSection>!
  
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
  private var iconDataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskIconSection>!
  
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
    saveButton.isHidden = false
    
    view.backgroundColor = Style.App.background
    
    hideKeyboardWhenTappedAround()
    
    // adding 1 layer
    view.addSubviews([
      textLabel,
      textField,
      textLenLabel,
      colorLabel,
      colorCollecionView,
      imageLabel,
      iconCollectionView,
      taskTypeImageContainerView
    ])

    // adding 2 layer
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

    textLabel.anchor(
      top: taskTypeImageContainerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 21,
      leftConstant: 16,
      rightConstant: 16)

    textField.returnKeyType = .done
    textField.anchor(
      top: textLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant)

    textLenLabel.anchor(
      top: textLabel.topAnchor,
      bottom: textLabel.bottomAnchor,
      right: view.rightAnchor,
      rightConstant: 16)

    colorLabel.anchor(
      top: textField.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16)

    colorCollecionView.register(KindOfTaskColorCell.self, forCellWithReuseIdentifier: KindOfTaskColorCell.reuseID)
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

    iconCollectionView.register(KindOfTaskIconCell.self, forCellWithReuseIdentifier: KindOfTaskIconCell.reuseID)
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
    colorDataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskColorSection>(
      configureCell: {_, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: KindOfTaskColorCell.reuseID,
          for: indexPath
        ) as? KindOfTaskColorCell else { return UICollectionViewCell() }
        cell.configure(with: item)
        return cell
      })

    iconCollectionView.dataSource = nil
    iconDataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskIconSection>(
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
      selectionColor: colorCollecionView.rx.itemSelected.asDriver(),
      selectionIcon: iconCollectionView.rx.itemSelected.asDriver(),
      text: textField.rx.text.orEmpty.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.navigateBack.drive(),
      outputs.dataSourceColor.drive(colorCollecionView.rx.items(dataSource: colorDataSource)),
      outputs.dataSourceIcon.drive(iconCollectionView.rx.items(dataSource: iconDataSource)),
      outputs.text.drive(textField.rx.text),
      outputs.save.drive(),
      outputs.selectIcon.drive(taskTypeImageView.rx.image),
      outputs.selectColor.drive(taskTypeImageView.rx.tintColor),
      outputs.textLen.drive(textLenLabel.rx.text)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
}
