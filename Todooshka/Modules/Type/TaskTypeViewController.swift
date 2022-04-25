//
//  TypeViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.09.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources

class TaskTypeViewController: TDViewController {
  
  //MARK: - Properties
  var viewModel: TaskTypeViewModel!
  let disposeBag = DisposeBag()
  
  private var colorDataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeColorSectionModel>!
  private var iconDataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeIconSectionModel>!
  
  //MARK: - UI Elements
  private let nameLabel = UILabel()
  private let taskTypeImageContainerView: UIView = {
    let view = UIView()
    view.cornerRadius = 16
    view.layer.borderWidth = 1
    view.layer.borderColor = Theme.Cell.border?.cgColor
    view.backgroundColor = Theme.Cell.background
    return view
  }()
  
  private let taskTypeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .clear
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let nameTextField = TDTaskTextField(placeholder: "Введите название типа")
  
  private let nameSymbolsCountLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.textColor = UIColor(red: 0.188, green: 0.2, blue: 0.325, alpha: 1)
    label.font = UIFont.systemFont(ofSize: 12.adjusted, weight: .medium)
    return label
  }()
  
  private let colorLabel: UILabel = {
    let label = UILabel()
    label.text = "Цвет:"
    label.font = UIFont.systemFont(ofSize: 15.adjusted, weight: .medium)
    return label
  }()
  
  private var colorCollectionView: UICollectionView!
  private let colorCollectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 48.adjusted, height: 48.adjusted)
    layout.minimumLineSpacing = 11.adjusted
    return layout
  }()
  
  private let imageLabel: UILabel = {
    let label = UILabel()
    label.text = "Значок:"
    label.font = UIFont.systemFont(ofSize: 15.adjusted, weight: .medium)
    return label
  }()
  
  private var imageCollectionView: UICollectionView!
  private let imageCollectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 62.adjusted, height: 62.adjusted)
    layout.minimumLineSpacing = 8
    return layout
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
    configureColor()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    viewModel.services.typesService.selectedTypeColor.accept(TaskType.Standart.Empty.color)
    viewModel.services.typesService.selectedTypeIcon.accept(TaskType.Standart.Empty.icon)
  }
  
  //MARK: - Configure UI
  func configureUI() {
    colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorCollectionViewLayout)
    imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionViewLayout)
    
    // adding subview
    view.addSubview(nameLabel)
    view.addSubview(nameTextField)
    view.addSubview(nameSymbolsCountLabel)
    view.addSubview(colorLabel)
    view.addSubview(colorCollectionView)
    view.addSubview(imageLabel)
    view.addSubview(imageCollectionView)
    view.addSubview(taskTypeImageContainerView)
    taskTypeImageContainerView.addSubview(taskTypeImageView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // keyboard
    hideKeyboardWhenTappedAround()
    
    // saveButton
    saveButton.isHidden = false
    
    // taskTypeImageContainerView
    taskTypeImageContainerView.anchor(top: headerView.bottomAnchor, topConstant: 16, widthConstant: 68.adjusted, heightConstant: 68.adjusted)
    taskTypeImageContainerView.anchorCenterXToSuperview()
    
    // taskTypeImageView
    taskTypeImageView.anchorCenterXToSuperview()
    taskTypeImageView.anchorCenterYToSuperview()
    
    // nameLabel
    nameLabel.text = "Название типа задач"
    nameLabel.font = UIFont.systemFont(ofSize: 15.adjusted, weight: .medium)
    nameLabel.textAlignment = .left
    nameLabel.anchor(top: taskTypeImageContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 21.adjusted, leftConstant: 16, rightConstant: 16)
    
    // nameTextField
    nameTextField.returnKeyType = .done
    nameTextField.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16, heightConstant: 40.adjusted)
    
    // nameSymbolsCountLabel
    nameSymbolsCountLabel.anchor(top: nameLabel.topAnchor, bottom: nameLabel.bottomAnchor, right: view.rightAnchor, rightConstant: 16)
    
    // colorLabel
    colorLabel.anchor(top: nameTextField.bottomAnchor, left: view.leftAnchor, topConstant: 16.adjusted, leftConstant: 16)
    
    // colorCollectionView
    colorCollectionView.register(TaskTypeColorCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeColorCollectionViewCell.reuseID)
    colorCollectionView.clipsToBounds = false
    colorCollectionView.isScrollEnabled = false
    colorCollectionView.backgroundColor = UIColor.clear
    colorCollectionView.anchor(top: colorLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 14.adjusted, leftConstant: 16, rightConstant: 16, heightConstant: (48 + 48 + 10).adjusted)
    
    // imageLabel
    imageLabel.anchor(top: colorCollectionView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16)
    
    // imageCollectionView
    imageCollectionView.register(TaskTypeIconCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeIconCollectionViewCell.reuseID)
    imageCollectionView.clipsToBounds = false
    imageCollectionView.isScrollEnabled = false
    imageCollectionView.backgroundColor = UIColor.clear
    imageCollectionView.anchor(top: imageLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16.adjusted, leftConstant: 16, rightConstant: 16, heightConstant: (62 * 4 + 8 * 3).adjusted)
  }
  
  //MARK: - Color CollectionView
  func configureDataSource() {
    colorCollectionView.dataSource = nil
    colorDataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeColorSectionModel>(
      configureCell: {(_, collectionView, indexPath, color) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeColorCollectionViewCell.reuseID, for: indexPath) as! TaskTypeColorCollectionViewCell
        let cellViewModel = TaskTypeColorCollectionViewCellModel(services: self.viewModel.services, color: color)
        cell.viewModel = cellViewModel
        return cell
      })
    
    imageCollectionView.dataSource = nil
    iconDataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeIconSectionModel>(
      configureCell: {(_, collectionView, indexPath, icon) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeIconCollectionViewCell.reuseID, for: indexPath) as! TaskTypeIconCollectionViewCell
        let cellViewModel = TaskTypeIconCollectionViewCellModel(services: self.viewModel.services, icon: icon)
        cell.viewModel = cellViewModel
        return cell
      })
    
  }
  
  //MARK: - Bind TO
  func bindViewModel() {
    
    nameTextField.text = viewModel.type.text
    
    let input = TaskTypeViewModel.Input(
      // buttons
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      saveButtonClickTrigger: saveButton.rx.tap.asDriver(),
      // text
      text: nameTextField.rx.text.orEmpty.asDriver(),
      // selection
      iconSelection: imageCollectionView.rx.itemSelected.asDriver(),
      colorSelection: colorCollectionView.rx.itemSelected.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    [
      // buttons
      output.backButtonClick.drive(),
      output.saveButtonClick.drive(),
      
      // text
      output.limitedText.drive(nameTextField.rx.text),
      output.limitedTextLength.drive(nameSymbolsCountLabel.rx.text),
      
      // dataSource
      output.iconDataSource.drive(imageCollectionView.rx.items(dataSource: iconDataSource)),
      output.colorDataSource.drive(colorCollectionView.rx.items(dataSource: colorDataSource)),
      
      // selection
      output.imageSelected.drive(taskTypeImageView.rx.image),
      output.colorSelected.drive(colorBinder)
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
  
  // MARK: - Binders
  var colorBinder: Binder<UIColor> {
    return Binder(self, binding: { (cell, color) in
      cell.taskTypeImageView.tintColor = color
    })
  }
}

extension TaskTypeViewController: ConfigureColorProtocol {
  func configureColor() {
    
  }
}
