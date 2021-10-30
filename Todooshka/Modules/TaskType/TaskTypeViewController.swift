//
//  TaskTypeViewController.swift
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
    view.layer.borderColor = UIColor(named: "taskTypeCellBorder")?.cgColor
    view.backgroundColor = UIColor(named: "taskTypeCellBackground")
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
    viewModel.services.coreDataService.selectedTaskTypeColor.accept(nil)
    viewModel.services.coreDataService.selectedTaskTypeIconName.accept(nil)
  }
  
  //MARK: - Configure UI
  func configureUI() {
    view.addSubview(taskTypeImageContainerView)
    taskTypeImageContainerView.anchor(top: headerView.bottomAnchor, topConstant: 16, widthConstant: 68.adjusted, heightConstant: 68.adjusted)
    taskTypeImageContainerView.anchorCenterXToSuperview()
    
    taskTypeImageContainerView.addSubview(taskTypeImageView)
    taskTypeImageView.anchorCenterXToSuperview()
    taskTypeImageView.anchorCenterYToSuperview()
    
    nameLabel.text = "Название типа задач"
    nameLabel.font = UIFont.systemFont(ofSize: 15.adjusted, weight: .medium)
    nameLabel.textAlignment = .left
    
    view.addSubview(nameLabel)
    nameLabel.anchor(top: taskTypeImageContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 21.adjusted, leftConstant: 16, rightConstant: 16)
    
    nameTextField.returnKeyType = .done
    view.addSubview(nameTextField)
    nameTextField.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16, heightConstant: 40.adjusted)
    
    view.addSubview(nameSymbolsCountLabel)
    nameSymbolsCountLabel.anchor(top: nameLabel.topAnchor, bottom: nameLabel.bottomAnchor, right: view.rightAnchor, rightConstant: 16)
    
    view.addSubview(colorLabel)
    colorLabel.anchor(top: nameTextField.bottomAnchor, left: view.leftAnchor, topConstant: 16.adjusted, leftConstant: 16)
    
    colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorCollectionViewLayout)
    colorCollectionView.register(TaskTypeColorCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeColorCollectionViewCell.reuseID)
    colorCollectionView.clipsToBounds = false
    colorCollectionView.isScrollEnabled = false
    colorCollectionView.backgroundColor = UIColor.clear
    
    view.addSubview(colorCollectionView)
    colorCollectionView.anchor(top: colorLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 14.adjusted, leftConstant: 16, rightConstant: 16, heightConstant: (48 + 48 + 10).adjusted)
   
    view.addSubview(imageLabel)
    imageLabel.anchor(top: colorCollectionView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16)
    
    imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionViewLayout)
    imageCollectionView.register(TaskTypeIconCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeIconCollectionViewCell.reuseID)
    imageCollectionView.clipsToBounds = false
    imageCollectionView.isScrollEnabled = false
    imageCollectionView.backgroundColor = UIColor.clear
    
    view.addSubview(imageCollectionView)
    imageCollectionView.anchor(top: imageLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16.adjusted, leftConstant: 16, rightConstant: 16, heightConstant: (62 * 4 + 8 * 3).adjusted)
        
    hideKeyboardWhenTappedAround()
  }
  
  //MARK: - Color CollectionView
  func configureDataSource() {
    colorCollectionView.dataSource = nil
    colorDataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeColorSectionModel>(
      configureCell: {(_, collectionView, indexPath, taskTypeColorItem) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeColorCollectionViewCell.reuseID, for: indexPath) as! TaskTypeColorCollectionViewCell
        let cellViewModel = TaskTypeColorCollectionViewCellModel(services: self.viewModel.services, taskTypeColorItem: taskTypeColorItem)
        cell.viewModel = cellViewModel
        return cell
      })
    
    imageCollectionView.dataSource = nil
    iconDataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeIconSectionModel>(
      configureCell: {(_, collectionView, indexPath, taskTypeIcon) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeIconCollectionViewCell.reuseID, for: indexPath) as! TaskTypeIconCollectionViewCell
        let cellViewModel = TaskTypeIconCollectionViewCellModel(services: self.viewModel.services, taskTypeIcon: taskTypeIcon)
        cell.viewModel = cellViewModel
        return cell
      })
    
  }
  
  //MARK: - Bind TO
  func bindViewModel() {
    
    saveButton.isHidden = false
    
    nameTextField.text = viewModel.taskType?.text
    
    let input = TaskTypeViewModel.Input(
      text: nameTextField.rx.text.orEmpty.asDriver(),
      colorSelection: colorCollectionView.rx.itemSelected.asDriver(),
      iconSelection: imageCollectionView.rx.itemSelected.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      saveButtonClickTrigger: saveButton.rx.tap.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    output.colorSelected.drive(taskTypeImageView.rx.tintColor).disposed(by: disposeBag)
    output.iconSelected.drive(taskTypeImageView.rx.image).disposed(by: disposeBag)
    output.backButtonClick.drive().disposed(by: disposeBag)
    output.colorDataSource.drive(colorCollectionView.rx.items(dataSource: colorDataSource)).disposed(by: disposeBag)
    output.iconDataSource.drive(imageCollectionView.rx.items(dataSource: iconDataSource)).disposed(by: disposeBag)
    output.limitedTextLength.drive(nameSymbolsCountLabel.rx.text).disposed(by: disposeBag)
    output.limitedText.drive(nameTextField.rx.text).disposed(by: disposeBag)
    output.saveType.drive().disposed(by: disposeBag)
  }
}

extension TaskTypeViewController: ConfigureColorProtocol {
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
  }
}
