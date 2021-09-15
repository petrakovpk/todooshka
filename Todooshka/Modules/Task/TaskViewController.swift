//
//  TaskViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class TaskViewController: UIViewController {
  
  //MARK: - Propertie
  private let disposeBag = DisposeBag()
  
  private var viewModel: TaskViewModel!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>!
  
  //MARK: - UI Elements
  private let taskTextField = TDTaskTextField()
  private let descriptionTextView = TDTaskCommentTextView()
  private let configureTaskTypesButton = UIButton(type: .custom)
  private let completeTaskButton = UIButton(type: .system)
  private let titleLabel = UILabel()
  private let saveTextButton = UIButton(type: .custom)
  private let saveDescriptionButton = UIButton(type: .custom)
  private let saveButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    button.semanticContentAttribute = .forceRightToLeft
    return button
  }()
  private let backButton = UIButton(type: .custom)
  private let errorLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .light)
    label.textColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    return label
  }()
  private var collectionView: UICollectionView!
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureDataSource()
    configureColor()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.viewDidDisappear()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    let headerView = UIView()
    headerView.backgroundColor = UIColor(named: "navigationBarBackground")
    
    view.addSubview(headerView)
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    
    headerView.addSubview(backButton)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    headerView.addSubview(saveButton)
    saveButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.textAlignment = .center
    
    headerView.addSubview(titleLabel)
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(left: backButton.rightAnchor, bottom: headerView.bottomAnchor, right: saveButton.leftAnchor, leftConstant: 0,  bottomConstant: 20, rightConstant: 0)
    
    let dividerView = UIView()
    dividerView.backgroundColor = UIColor(named: "navigationBarDividerBackground")
    
    headerView.addSubview(dividerView)
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    let label1 = UILabel(text: "Задача")
    label1.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label1.textAlignment = .left
    
    view.addSubview(label1)
    label1.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 21, leftConstant: 16, rightConstant: 16)
    
    saveDescriptionButton.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    
    view.addSubview(taskTextField)
    taskTextField.anchor(top: label1.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 5, leftConstant: 16, rightConstant: 16, heightConstant: 40)
    
    saveTextButton.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    
    view.addSubview(saveTextButton)
    saveTextButton.anchor(right: taskTextField.rightAnchor, widthConstant: 24, heightConstant: 24)
    saveTextButton.centerYAnchor.constraint(equalTo: taskTextField.centerYAnchor).isActive = true
    
    let label2 = UILabel(text: "Тип")
    label2.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label2.textAlignment = .left
    
    view.addSubview(label2)
    label2.anchor(top: taskTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 30, leftConstant: 16, rightConstant: 16)
    
    configureTaskTypesButton.setImage(UIImage(named: "settings")?.template , for: .normal)
    view.addSubview(configureTaskTypesButton)
    configureTaskTypesButton.centerYAnchor.constraint(equalTo: label2.centerYAnchor).isActive = true
    configureTaskTypesButton.anchor(right: view.rightAnchor, rightConstant: 16)
    
    view.addSubview(errorLabel)
    errorLabel.anchor(top: label2.bottomAnchor, left: view.leftAnchor, topConstant: 4, leftConstant: 16)
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    collectionView.register(TaskTypeCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeCollectionViewCell.reuseID)
    collectionView.isScrollEnabled = false
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    
    view.addSubview(collectionView)
    collectionView.anchor(top: label2.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20, leftConstant: 16, heightConstant: 100)
    
    let label3 = UILabel(text: "Комментарий (если требуется)")
    label3.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label3.textAlignment = .left
    
    view.addSubview(label3)
    label3.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20, leftConstant: 16, rightConstant: 16)
    
    saveDescriptionButton.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    
    view.addSubview(saveDescriptionButton)
    saveDescriptionButton.centerYAnchor.constraint(equalTo: label3.centerYAnchor).isActive = true
    saveDescriptionButton.anchor(right: view.rightAnchor, rightConstant: 16)
    
    view.addSubview(completeTaskButton)
    completeTaskButton.cornerRadius = 48 / 2
    completeTaskButton.setTitle("Выполнено!", for: .normal)
    completeTaskButton.setTitleColor(.black, for: .normal)
    completeTaskButton.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
    completeTaskButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,  leftConstant: 16, bottomConstant: 346 + 8, rightConstant: 16, heightConstant: 48)
    
    view.addSubview(descriptionTextView)
    descriptionTextView.anchor(top: label3.bottomAnchor, left: view.leftAnchor, bottom: completeTaskButton.topAnchor,  right: view.rightAnchor, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
    
    let dividerView1 = UIView()
    dividerView1.backgroundColor = UIColor(red: 0.094, green: 0.105, blue: 0.233, alpha: 1)
    
    view.addSubview(dividerView1)
    dividerView1.anchor(left: descriptionTextView.leftAnchor, bottom: descriptionTextView.bottomAnchor, right: descriptionTextView.rightAnchor,  heightConstant: 1.0)
  }
  
  //MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(90), heightDimension: .absolute(91))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(90), heightDimension: .estimated(91))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  //MARK: - Bind
  func bindTo(with viewModel: TaskViewModel) {
    self.viewModel = viewModel
    
    bindOutputs()
    bindInputs()
  }
  
  //From ViewController To ViewModel
  func bindInputs() {
    backButton.rx.tap.bind{ self.viewModel.leftBarButtonBackItemClick()}.disposed(by: disposeBag)
    saveButton.rx.tap.bind{ self.viewModel.rightBarButtonSaveItemClick() }.disposed(by: disposeBag)
    configureTaskTypesButton.rx.tap.bind{ self.viewModel.configureTaskTypesButtonClick() }.disposed(by: disposeBag)
    completeTaskButton.rx.tap.bind{ self.viewModel.completeButtonClick() }.disposed(by: disposeBag)
    
    taskTextField.rx.text.orEmpty.bind(to: self.viewModel.taskTextInput).disposed(by: disposeBag)
    descriptionTextView.rx.text.orEmpty.bind{ [weak self] description in
      guard let self = self else { return }
      if self.descriptionTextView.textColor == UIColor(named: "appText") {
        self.viewModel.taskDescriptionInput.accept(description)
      }
    }.disposed(by: disposeBag)
    
    saveTextButton.rx.tap.bind{ [weak self] _ in
      guard let self = self else { return }
      self.saveTextButton.isHidden = true
      self.taskTextField.resignFirstResponder()
      self.viewModel.saveTextButtonClick()
    }.disposed(by: disposeBag)
    
    saveDescriptionButton.rx.tap.bind{ [weak self] _ in
      guard let self = self else { return }
      self.saveDescriptionButton.isHidden = true
      self.descriptionTextView.resignFirstResponder()
      self.viewModel.saveDescriptionButtonClick()
    }.disposed(by: disposeBag)
    
    descriptionTextView.rx.didBeginEditing.bind{ [weak self] _ in
      guard let self = self else { return }
      if self.descriptionTextView.textColor == UIColor(named: "taskPlaceholderText") {
        self.descriptionTextView.clear()
        self.descriptionTextView.textColor = UIColor(named: "appText")
      }
    }.disposed(by: disposeBag)
    
    descriptionTextView.rx.didEndEditing.bind { [weak self] _ in
      guard let self = self else { return }
      if self.descriptionTextView.text.isEmpty {
        self.descriptionTextView.textColor = UIColor(named: "taskPlaceholderText")
        self.descriptionTextView.text = "Напишите комментарий"
      }
    }.disposed(by: disposeBag)
    
    descriptionTextView.rx.didChange.bind{ [weak self] _ in
      guard let self = self else { return }
      if self.viewModel.task.value != nil {
        self.saveDescriptionButton.isHidden = false
      }
    }.disposed(by: disposeBag)
    
    taskTextField.rx.controlEvent([.editingChanged]).bind{[weak self] _ in
      guard let self = self else { return }
      if self.viewModel.task.value != nil {
        self.saveTextButton.isHidden = false
      }
    }.disposed(by: disposeBag)
    
    taskTextField.rx.controlEvent([.editingDidEndOnExit]).bind{[weak self] _ in
      guard let self = self else { return }
      
      if self.viewModel.task.value == nil {
        self.viewModel.rightBarButtonSaveItemClick()
      } else {
        self.saveTextButton.isHidden = true
        self.viewModel.saveTextButtonClick()
      }
      
    }.disposed(by: disposeBag)
    
  }
  
  //From ViewModel To ViewController
  func bindOutputs() {
    viewModel.taskTextOutput.bind(to: taskTextField.rx.text).disposed(by: disposeBag)
    viewModel.errorLabelOutput.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
    viewModel.taskDescriptionOutput.bind{ [weak self] description in
      guard let self = self else { return }
      guard let description = description else { return }
      if description != "" {
        self.descriptionTextView.textColor = UIColor(named: "appText")
        self.descriptionTextView.text = description
      }
    }.disposed(by: disposeBag)
    
    viewModel.taskTypeOutput.bind{ [weak self] type in
      guard let self = self else { return }
      guard let type = type else { return }
      self.viewModel.services.coreDataService.selectedTaskType.accept(type)
    }.disposed(by: disposeBag)
    
    viewModel.task.bind{ [weak self] task in
      guard let self = self else { return }
      if let task = task {
        self.saveDescriptionButton.isHidden = true
        self.saveTextButton.isHidden = true
        self.saveButton.isHidden = true
        self.backButton.isHidden = false
        self.titleLabel.text = task.text
        self.completeTaskButton.isHidden = false
      } else {
        self.saveDescriptionButton.isHidden = true
        self.saveTextButton.isHidden = true
        self.saveButton.isHidden = false
        self.titleLabel.text = "Создать задачу"
        self.completeTaskButton.isHidden = true
        self.taskTextField.becomeFirstResponder()
        
        if self.viewModel.status == .created {
          self.backButton.isHidden = true
        } else {
          self.backButton.isHidden = false
        }
        
      }
    }.disposed(by: disposeBag)

    
  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>(
      configureCell: {(_, collectionView, indexPath, type) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeCollectionViewCell.reuseID, for: indexPath) as! TaskTypeCollectionViewCell
        let cellViewModel = TaskTypeCollectionViewCellModel(services: self.viewModel.services, type: type)
        cell.bindToViewModel(viewModel: cellViewModel)
        return cell
      })
    
    viewModel.dataSource.asDriver()
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.bind{[weak self] indexPath in
      guard let self = self else { return }
      guard let types = self.viewModel.dataSource.value.first?.items else { return }
      self.viewModel.taskTypeInput.accept(types[indexPath.item])
    }.disposed(by: disposeBag)
  }
}


extension TaskViewController: ConfigureColorProtocol {
  
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    backButton.imageView?.tintColor = UIColor(named: "appText")
    
    configureTaskTypesButton.imageView?.tintColor = UIColor(named: "taskTypeSettingsButtonTint")
  }

}
