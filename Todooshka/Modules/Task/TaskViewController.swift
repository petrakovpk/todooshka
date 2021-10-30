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
import Lottie

class TaskViewController: TDViewController {
  
  //MARK: - Propertie
  var viewModel: TaskViewModel!
  
  private let disposeBag = DisposeBag()
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>!
  
  //MARK: - UI Elements
  private let textField = TDTaskTextField(placeholder: "Введите название задачи")
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.borderWidth = 0
    textView.backgroundColor = .clear
    textView.font = UIFont.systemFont(ofSize: 13.adjusted, weight: .medium)
    return textView
  }()
  
  private let configureTaskTypesButton = UIButton(type: .custom)
  private let completeTaskButton = UIButton(type: .system)
  
  private let saveTextButton = UIButton(type: .custom)
  private let saveDescriptionButton = UIButton(type: .custom)
  
  private let errorLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12.adjusted, weight: .light)
    label.textColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    return label
  }()
  private var collectionView: UICollectionView!
  
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let okAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    button.cornerRadius = 48.superAdjusted / 2
    button.setTitle("Да, я молодец :)", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    return button
  }()
  
  private var animationView = AnimationView(name: "taskDone2")
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
    configureColor()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.viewDidDisappear()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    let label1 = UILabel(text: "Задача")
    label1.font = UIFont.systemFont(ofSize: 15.adjusted , weight: .medium)
    label1.textAlignment = .left
    
    view.addSubview(label1)
    label1.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 21.superAdjusted, leftConstant: 16, rightConstant: 16)
    
    saveDescriptionButton.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    
    textField.returnKeyType = .done
    view.addSubview(textField)
    textField.anchor(top: label1.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 5.superAdjusted, leftConstant: 16, rightConstant: 16, heightConstant: 40.superAdjusted)
    
    saveTextButton.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    
    view.addSubview(saveTextButton)
    saveTextButton.anchor(right: textField.rightAnchor, widthConstant: 24.adjusted, heightConstant: 24.superAdjusted )
    saveTextButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
    
    let label2 = UILabel(text: "Тип")
    label2.font = UIFont.systemFont(ofSize: 15.adjusted, weight: .medium)
    label2.textAlignment = .left
    
    view.addSubview(label2)
    label2.anchor(top: textField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 30.superAdjusted, leftConstant: 16, rightConstant: 16)
    
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
    collectionView.anchor(top: label2.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20.superAdjusted, leftConstant: 16, heightConstant: 100.superAdjusted )
    
    let label3 = UILabel(text: "Комментарий (если требуется)")
    label3.font = UIFont.systemFont(ofSize: 15.adjusted, weight: .medium)
    label3.textAlignment = .left
    
    view.addSubview(label3)
    label3.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20.superAdjusted, leftConstant: 16, rightConstant: 16)
    
    saveDescriptionButton.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    
    view.addSubview(saveDescriptionButton)
    saveDescriptionButton.centerYAnchor.constraint(equalTo: label3.centerYAnchor).isActive = true
    saveDescriptionButton.anchor(right: view.rightAnchor, rightConstant: 16)
    
    view.addSubview(completeTaskButton)
    completeTaskButton.cornerRadius = 48.superAdjusted / 2
    completeTaskButton.setTitle("Выполнено!", for: .normal)
    completeTaskButton.setTitleColor(.black, for: .normal)
    completeTaskButton.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
    completeTaskButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,  leftConstant: 16, bottomConstant: (346 + 8).superAdjusted, rightConstant: 16, heightConstant: 48.superAdjusted)
    
    view.addSubview(descriptionTextView)
    descriptionTextView.anchor(top: label3.bottomAnchor, left: view.leftAnchor, bottom: completeTaskButton.topAnchor,  right: view.rightAnchor, leftConstant: 16, bottomConstant: 16.superAdjusted, rightConstant: 16)
    
    let dividerView1 = UIView()
    dividerView1.backgroundColor = UIColor(red: 0.094, green: 0.105, blue: 0.233, alpha: 1)
    
    view.addSubview(dividerView1)
    dividerView1.anchor(left: descriptionTextView.leftAnchor, bottom: descriptionTextView.bottomAnchor, right: descriptionTextView.rightAnchor,  heightConstant: 1.0)
    
    saveButton.isHidden = false
    saveTextButton.isHidden = true
    saveDescriptionButton.isHidden = true
  }
  
  private func configureAlert() {
    view.addSubview(alertBackgroundView)
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    animationView.isHidden = true
    
    animationView.contentMode = .scaleAspectFill
    animationView.loopMode = .repeat(3.0)
    animationView.animationSpeed = 1.0
    
    view.addSubview(animationView)
    animationView.anchorCenterXToSuperview()
    animationView.anchorCenterYToSuperview()
    
    animationView.addSubview(okAlertButton)
    okAlertButton.anchor(top: completeTaskButton.topAnchor, left: completeTaskButton.leftAnchor, bottom: completeTaskButton.bottomAnchor, right: completeTaskButton.rightAnchor)
    
  }
  
  //MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(90.superAdjusted), heightDimension: .absolute(91.superAdjusted ))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(90.superAdjusted), heightDimension: .estimated(91.superAdjusted))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  //MARK: - Bind
  func bindViewModel() {
    
    if let task = viewModel.task {
      textField.text = task.text
      descriptionTextView.text = task.description
      completeTaskButton.isHidden = task.status == .completed
    } else {
      textField.becomeFirstResponder()
      completeTaskButton.isHidden = true
    }
 
    let input = TaskViewModel.Input(
      text: textField.rx.text.orEmpty.asDriver(),
      description: descriptionTextView.rx.text.orEmpty.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver(),
      descriptionTextViewDidBeginEditing: descriptionTextView.rx.didBeginEditing.asDriver(),
      descriptionTextViewDidEndEditing: descriptionTextView.rx.didEndEditing.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      configureTaskTypesButtonClickTrigger: configureTaskTypesButton.rx.tap.asDriver(),
      saveTaskButtonClickTrigger: saveButton.rx.tap.asDriver(),
      saveDescriptionButtonClickTrigger: saveDescriptionButton.rx.tap.asDriver(),
      completeButtonClickTrigger: completeTaskButton.rx.tap.asDriver(),
      okAlertButtonClickTrigger: okAlertButton.rx.tap.asDriver(),
      textFieldEditingDidEndOnExit: textField.rx.controlEvent([.editingDidEndOnExit]).asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    output.placeholderIsOn.drive(placeholderBinder).disposed(by: disposeBag)
    output.errorTextLabel.drive(errorLabel.rx.text).disposed(by: disposeBag)
    output.completeButtonClick.drive(showAlertBinder).disposed(by: disposeBag)
    output.okAlertButtonClick.drive(hideAlertBinder).disposed(by: disposeBag)
    output.backButtonClick.drive().disposed(by: disposeBag)
    output.saveButtonClick.drive().disposed(by: disposeBag)
    output.configureTaskTypeButtonClick.drive().disposed(by: disposeBag)
    output.dataSource.drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
      
  }
  
  //MARK: - Binders
  var placeholderBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, placeholderIsOn) in
      if placeholderIsOn {
        vc.descriptionTextView.textColor = UIColor(named: "taskPlaceholderText")
        vc.descriptionTextView.text = "Напишите комментарий"
      } else {
        
        if vc.descriptionTextView.textColor == UIColor(named: "taskPlaceholderText") {
          vc.descriptionTextView.text = ""
        }
        
        vc.descriptionTextView.textColor = UIColor(named: "appText")
      }
    })
  }
  
  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      self.animationView.animation = Animation.named("taskDone1")
      self.animationView.removeAllConstraints()
      self.animationView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor)
      self.animationView.play()
      
      let okButtonTexts = ["Да, я молодец!","Просто герой :)","Красавчик же","Светлое будущее приближается :)"]
      self.okAlertButton.setTitle(okButtonTexts.randomElement(), for: .normal)
      self.alertBackgroundView.isHidden = false
      self.animationView.isHidden = false
    })
  }
  
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
    self.alertBackgroundView.isHidden = true
    self.animationView.isHidden = true
    })
  }

  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>(
      configureCell: {(_, collectionView, indexPath, type) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeCollectionViewCell.reuseID, for: indexPath) as! TaskTypeCollectionViewCell
        let cellViewModel = TaskTypeCollectionViewCellModel(services: self.viewModel.services, type: type)
        cell.viewModel = cellViewModel
        return cell
      })
    
  
  }
}


extension TaskViewController: ConfigureColorProtocol {
  
  func configureColor() {
    configureTaskTypesButton.imageView?.tintColor = UIColor(named: "taskTypeSettingsButtonTint")
  }
  
}
