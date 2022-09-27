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
import RxGesture

class TaskViewController: TDViewController {
  
  // MARK: - Propertie
  var viewModel: TaskViewModel!
  
  private let disposeBag = DisposeBag()
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TypeLargeCollectionViewCellSectionModel>!
  
  // MARK: - Task UI Elements
  private let textLabel: UILabel = {
    let label = UILabel(text: "Задача")
    label.font = UIFont.systemFont(ofSize: 15.adjusted , weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let kindOfTaskLabel: UILabel = {
    let label = UILabel(text: "Тип")
    label.font = UIFont.systemFont(ofSize: 15.adjusted , weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel(text: "Комментарий (если требуется)")
    label.font = UIFont.systemFont(ofSize: 15.adjusted , weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.094, green: 0.105, blue: 0.233, alpha: 1)
    return view
  }()
  
  private let textTextField: TDTaskTextField = {
    let field = TDTaskTextField(placeholder: "Введите название задачи")
    field.returnKeyType = .done
    return field
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.borderWidth = 0
    textView.backgroundColor = .clear
    textView.font = UIFont.systemFont(ofSize: 13.adjusted, weight: .medium)
    return textView
  }()
  
  private let kindsOfTaskButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "settings")?.template , for: .normal)
    button.tintColor = Theme.Buttons.RoundButton.tint
    return button
  }()
  
  private let completeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 48.superAdjusted / 2
    button.setTitle("Выполнено!", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
    return button
  }()
  
  private var collectionView: UICollectionView!
  
  // MARK: - Complete Task Alert UI Elements
  private let alertView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let alertButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 48.superAdjusted / 2
    button.setTitle("Да, я молодец :)", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    return button
  }()
  
  private let alertAnimationView: AnimationView = {
    let animationView = AnimationView(name: "taskDone2")
    animationView.isHidden = true
    animationView.contentMode = .scaleAspectFill
    animationView.loopMode = .repeat(3.0)
    animationView.animationSpeed = 1.0
    return animationView
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }
  
//  override func viewDidDisappear(_ animated: Bool) {
//    if isModal && viewModel.services.tabBarService.selectedItem.value == .Left {
//      //viewModel.services.actionService.runNestSceneActionsTrigger.accept(())
//    }
//  }
  
  //MARK: - Configure UI
  private func configureUI() {
    
    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(textLabel)
    view.addSubview(textTextField)
    view.addSubview(kindOfTaskLabel)
    view.addSubview(kindsOfTaskButton)
    view.addSubview(collectionView)
    view.addSubview(descriptionLabel)
    view.addSubview(descriptionTextView)
    view.addSubview(dividerView)
    view.addSubview(completeButton)
    
    // saveButton
    saveButton.isHidden = false
    
    // nameLabel
    textLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 21.superAdjusted, leftConstant: 16, rightConstant: 16)
    
    // nameTextField
    textTextField.anchor(top: textLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 5.superAdjusted, leftConstant: 16, rightConstant: 16, heightConstant: 40.superAdjusted)
    
    // kindOfTaskLabel
    kindOfTaskLabel.anchor(top: textTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16.superAdjusted, leftConstant: 16, rightConstant: 16)
    
    // configureTaskTypesButton
   
    kindsOfTaskButton.centerYAnchor.constraint(equalTo: kindOfTaskLabel.centerYAnchor).isActive = true
    kindsOfTaskButton.anchor(right: view.rightAnchor, rightConstant: 16)
    
    // collectionView
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.register(TypeLargeCollectionViewCell.self, forCellWithReuseIdentifier: TypeLargeCollectionViewCell.reuseID)
    collectionView.anchor(top: kindOfTaskLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20.superAdjusted, leftConstant: 16, heightConstant: 100.superAdjusted )
    
    // descriptionLabel
    descriptionLabel.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20.superAdjusted, leftConstant: 16, rightConstant: 16)
    
    // descriptionTextView
    descriptionTextView.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor,  right: view.rightAnchor, leftConstant: 16, bottomConstant: 16.superAdjusted, rightConstant: 16, heightConstant: 100)
    
    // dividerView
    dividerView.anchor(left: descriptionTextView.leftAnchor, bottom: descriptionTextView.bottomAnchor, right: descriptionTextView.rightAnchor,  heightConstant: 1.0)
    
    // completeTaskButton
    completeButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,  leftConstant: 16, bottomConstant: 16, rightConstant: 16, heightConstant: 48.superAdjusted)
    
    // hideKeyboardWhenTappedAround
    hideKeyboardWhenTappedAround()
  }
  
  private func configureAlert() {
    
    // adding
    view.addSubview(alertView)
    view.addSubview(alertAnimationView)
    alertAnimationView.addSubview(alertButton)
    
    // alertView
    alertView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // alertAnimationView
    alertAnimationView.anchorCenterXToSuperview()
    alertAnimationView.anchorCenterYToSuperview()
    
    // alertButton
    alertButton.anchor(top: completeButton.topAnchor, left: completeButton.leftAnchor, bottom: completeButton.bottomAnchor, right: completeButton.rightAnchor)
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

    let input = TaskViewModel.Input(
      // textTextField
      textTextFieldText: textTextField.rx.text.orEmpty.asDriver(),
      textFieldEditingDidEndOnExit: textTextField.rx.controlEvent([.editingDidEndOnExit]).asDriver(),
      // descriptionTextField
      descriptionTextViewText: descriptionTextView.rx.text.orEmpty.asDriver(),
      descriptionTextViewDidBeginEditing: descriptionTextView.rx.didBeginEditing.asDriver(),
      descriptionTextViewDidEndEditing: descriptionTextView.rx.didEndEditing.asDriver(),
      // collectionView
      selection: collectionView.rx.itemSelected.asDriver(),
      // buttons
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      configureTaskTypesButtonClickTrigger: kindsOfTaskButton.rx.tap.asDriver(),
      saveTaskButtonClickTrigger: saveButton.rx.tap.asDriver(),
      completeButtonClickTrigger: completeButton.rx.tap.asDriver(),
      // Complete Task Alert
      alertOkButtonClickTrigger: alertButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.clearDescriptionPlaceholder.drive(clearDescriptionPlaceholderBinder),
      outputs.configureKindsOfTask.drive(),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.descriptionTextField.drive(descriptionTextView.rx.text),
      outputs.navigateBack.drive(),
      outputs.save.drive(),
      outputs.setDescriptionPlaceholder.drive(setDescriptionPlaceholderBinder),
      outputs.showAlertTrigger.drive(showAlertBinder),
      outputs.hideAlertTrigger.drive(hideAlertBinder),
      outputs.taskIsNewTrigger.drive(taskIsNewBinder),
      outputs.textTextField.drive(textTextField.rx.text),
    ]
      .forEach({ $0.disposed(by: disposeBag) })
    
  }
  
  // MARK: - Binders
  var clearDescriptionPlaceholderBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.descriptionTextView.textColor = Theme.App.text
      vc.descriptionTextView.clear()
    })
  }
  
  var setDescriptionPlaceholderBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.descriptionTextView.textColor = Theme.App.placeholder
      vc.descriptionTextView.text = "Напишите комментарий"
    })
  }
  
  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      let texts = ["Да, я молодец!","Просто герой :)","Красавчик же","Светлое будущее приближается :)"]
      
      // alertView
      vc.alertView.isHidden = false
      
      // alertAnimationView
      vc.alertAnimationView.isHidden = false
      vc.alertAnimationView.animation = Animation.named("taskDone1")
      vc.alertAnimationView.removeAllConstraints()
      vc.alertAnimationView.anchor(top: vc.view.topAnchor, left: vc.view.leftAnchor, bottom: vc.view.bottomAnchor, right: vc.view.rightAnchor)
      vc.alertAnimationView.play()
      
      // alertButton
      vc.alertButton.setTitle(texts.randomElement(), for: .normal)
    })
  }
  
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertView.isHidden = true
      vc.alertAnimationView.isHidden = true
    })
  }
  
  var taskIsNewBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
        vc.completeButton.isHidden = true
        vc.textTextField.becomeFirstResponder()
//        vc.completeButton.isHidden = false
//        vc.hideKeyboardWhenTappedAround()
      
    })
  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TypeLargeCollectionViewCellSectionModel>(
      configureCell: {(_, collectionView, indexPath, item) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeLargeCollectionViewCell.reuseID, for: indexPath) as! TypeLargeCollectionViewCell
        cell.configure(kindOfTask: item.kindOfTask, isSelected: item.isSelected)
        return cell
      })
  }
}
