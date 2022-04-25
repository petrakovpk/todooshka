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
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>!
  
  // MARK: - Task UI Elements
  private let nameLabel: UILabel = {
    let label = UILabel(text: "Задача")
    label.font = UIFont.systemFont(ofSize: 15.adjusted , weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let typeLabel: UILabel = {
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
  
  private let nameTextField: TDTaskTextField = {
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
  
  private let dateButton: UIButton = {
    let button = UIButton(type: .custom)
    button.layer.cornerRadius = 5
    button.layer.borderWidth = 1.0
    button.layer.borderColor = Theme.Cell.border?.cgColor
    button.backgroundColor = Theme.Cell.background
    
    let attrString = NSAttributedString(string: "Сегодня", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.strokeColor: Theme.App.text])
    button.setAttributedTitle(attrString, for: .normal)
    
    return button
  }()
  
  private let timeButton: UIButton = {
    let button = UIButton(type: .custom)
    button.layer.cornerRadius = 5
    button.layer.borderWidth = 1.0
    button.layer.borderColor = Theme.Cell.border?.cgColor
    button.backgroundColor = Theme.Cell.background
    
    let attrString = NSAttributedString(string: "В течение дня", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.strokeColor: Theme.App.text])
    button.setAttributedTitle(attrString, for: .normal)
    
    return button
  }()
  
  private let typesButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "settings")?.template , for: .normal)
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
  
  private let errorLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12.adjusted, weight: .light)
    label.textColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    return label
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
    let button = UIButton(type: .custom)
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
  
  //MARK: - Configure UI
  private func configureUI() {
    
    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(nameLabel)
    view.addSubview(nameTextField)
    view.addSubview(typeLabel)
    view.addSubview(typesButton)
    view.addSubview(errorLabel)
    view.addSubview(collectionView)
    view.addSubview(descriptionLabel)
    view.addSubview(descriptionTextView)
    view.addSubview(dividerView)
    view.addSubview(completeButton)
    
    // saveButton
    saveButton.isHidden = false
    
    // nameLabel
    nameLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 21.superAdjusted, leftConstant: 16, rightConstant: 16)
    
    // nameTextField
    nameTextField.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 5.superAdjusted, leftConstant: 16, rightConstant: 16, heightConstant: 40.superAdjusted)
    
    // typeLabel
    typeLabel.anchor(top: nameTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16.superAdjusted, leftConstant: 16, rightConstant: 16)
    
    // configureTaskTypesButton
    typesButton.imageView?.tintColor = Theme.RoundButton.tint
    typesButton.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor).isActive = true
    typesButton.anchor(right: view.rightAnchor, rightConstant: 16)
    
    // errorLabel
    errorLabel.anchor(top: typeLabel.bottomAnchor, left: view.leftAnchor, topConstant: 4, leftConstant: 16)
    
    // collectionView
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.register(TypeLargeCollectionViewCell.self, forCellWithReuseIdentifier: TypeLargeCollectionViewCell.reuseID)
    collectionView.anchor(top: typeLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20.superAdjusted, leftConstant: 16, heightConstant: 100.superAdjusted )
    
    // descriptionLabel
    descriptionLabel.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20.superAdjusted, leftConstant: 16, rightConstant: 16)
    
    // descriptionTextView
    descriptionTextView.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor,  right: view.rightAnchor, leftConstant: 16, bottomConstant: 16.superAdjusted, rightConstant: 16, heightConstant: 100)
    
    // dividerView
    dividerView.anchor(left: descriptionTextView.leftAnchor, bottom: descriptionTextView.bottomAnchor, right: descriptionTextView.rightAnchor,  heightConstant: 1.0)
    
    // completeTaskButton
    completeButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,  leftConstant: 16, bottomConstant: 16, rightConstant: 16, heightConstant: 48.superAdjusted)
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
    
    descriptionTextView.text = viewModel.task.description
    
    let input = TaskViewModel.Input(
      // nameTextField
      text: nameTextField.rx.text.orEmpty.asDriver(),
      textFieldEditingDidEndOnExit: nameTextField.rx.controlEvent([.editingDidEndOnExit]).asDriver(),
      // descriptionTextField
      description: descriptionTextView.rx.text.orEmpty.asDriver(),
      descriptionTextViewDidBeginEditing: descriptionTextView.rx.didBeginEditing.asDriver(),
      descriptionTextViewDidEndEditing: descriptionTextView.rx.didEndEditing.asDriver(),
      // collectionView
      selection: collectionView.rx.itemSelected.asDriver(),
      // buttons
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      configureTaskTypesButtonClickTrigger: typesButton.rx.tap.asDriver(),
      saveTaskButtonClickTrigger: saveButton.rx.tap.asDriver(),
      completeButtonClickTrigger: completeButton.rx.tap.asDriver(),
      // Complete Task Alert
      alertCompleteTaskOkButtonClickTrigger: alertButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // textChanging
      outputs.text.drive(nameTextField.rx.text),
      // descriptionTextField
      outputs.descriptionWithPlaceholder.drive(descriptionWithPlaceholderBinder),
      // typeChanging
     // outputs.typeChanging.drive(),
      // collectionView
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.selection.drive(),
      // buttons
      outputs.navigateBack.drive(),
      outputs.configureTaskTypesButtonClick.drive(),
      // alert
      outputs.showAlert.drive(showAlertBinder),
      outputs.hideAlert.drive(hideAlertBinder),
      // save
      outputs.saveTask.drive(),
      // point
      outputs.getPoint.drive(),
      // egg
      outputs.createEgg.drive(),
      outputs.removeEgg.drive(),
      // isNew
      outputs.taskIsNew.drive(taskIsNewBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
    
  }
  
  //MARK: - Binders
  var descriptionWithPlaceholderBinder: Binder<(Bool, String)> {
    return Binder(self, binding: { (vc, descriptionWithPlaceholder) in
      let (showDescriptionPlaceholder, description) = descriptionWithPlaceholder
      if showDescriptionPlaceholder {
        vc.descriptionTextView.textColor = Theme.App.placeholder
        vc.descriptionTextView.text = "Напишите комментарий"
      } else {
        vc.descriptionTextView.textColor = Theme.App.text
        vc.descriptionTextView.text = description
      }
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
  
  var taskIsNewBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, isNew) in
      if isNew {
        vc.completeButton.isHidden = true
        vc.nameTextField.becomeFirstResponder()
      } else {
        vc.completeButton.isHidden = false
        vc.hideKeyboardWhenTappedAround()
      }
    })
  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>(
      configureCell: {(_, collectionView, indexPath, type) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeLargeCollectionViewCell.reuseID, for: indexPath) as! TypeLargeCollectionViewCell
        cell.configure(with: type)
        return cell
      })
  }
}
