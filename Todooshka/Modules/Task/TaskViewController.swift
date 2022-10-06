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
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskSection>!
  
  // MARK: - Task UI Elements
  private let textLabel: UILabel = {
    let label = UILabel(text: "Задача")
    label.font = UIFont.systemFont(ofSize: 15.adjusted , weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let textTextField: TDTaskTextField = {
    let field = TDTaskTextField(placeholder: "Введите название задачи")
    field.returnKeyType = .done
    return field
  }()
  
  private let kindOfTaskLabel: UILabel = {
    let label = UILabel(text: "Тип")
    label.font = UIFont.systemFont(ofSize: 15.adjusted , weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let kindsOfTaskButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "settings")?.template , for: .normal)
    button.tintColor = Theme.Buttons.RoundButton.tint
    return button
  }()
  
  private let plannedDateButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(Theme.App.text, for: .normal)
    button.cornerRadius = 15
    button.borderWidth = 1.0
    button.borderColor = Theme.Cells.KindOfTask.Border
    return button
  }()
  
  private var collectionView: UICollectionView!
  
  private let descriptionLabel: UILabel = {
    let label = UILabel(text: "Комментарий")
    label.font = UIFont.systemFont(ofSize: 15.adjusted , weight: .medium)
    label.textAlignment = .left
    return label
  }()

  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.borderWidth = 0
    textView.backgroundColor = .clear
    textView.font = UIFont.systemFont(ofSize: 13.adjusted, weight: .medium)
    return textView
  }()
  
  private let dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.094, green: 0.105, blue: 0.233, alpha: 1)
    return view
  }()
  
  private let completeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 48.superAdjusted / 2
    button.setTitle("Выполнено!", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
    return button
  }()
  
  // MARK: - Complete Task Alert UI Elements
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let alertOkButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 48.superAdjusted / 2
    button.setTitle("Да, я молодец :)", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Theme.Buttons.AlertRoseButton.Background
    button.isHidden = true
    return button
  }()
  
  private let alertAnimationView: AnimationView = {
    let animationView = AnimationView(name: "taskDone2")
    animationView.isHidden = true
    animationView.contentMode = .scaleAspectFill
    animationView.loopMode = .repeat(3.0)
    animationView.animationSpeed = 1.0
    animationView.isHidden = true
    return animationView
  }()
  
  private let alertDatePicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.datePickerMode = .date
    picker.preferredDatePickerStyle = .inline
    picker.backgroundColor = Theme.App.background
    picker.cornerRadius = 15
    picker.isHidden = true
    return picker
  }()
  
  private let alertDatePickerOkButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 12
    button.setTitle("Выбрать", for: .normal)
    button.setTitleColor(Theme.App.text, for: .normal)
    button.backgroundColor = Palette.SingleColors.Portage
    button.isHidden = true
    return button
  }()
  
  private let alertDatePickerCancelButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 12
    button.setTitle("Отмена", for: .normal)
    button.setTitleColor(Theme.App.text, for: .normal)
    button.backgroundColor = Theme.App.background
    button.isHidden = true
    return button
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
    view.addSubviews([
      textLabel,
      textTextField,
      kindOfTaskLabel,
      kindsOfTaskButton,
      collectionView,
      plannedDateButton,
      descriptionLabel,
      descriptionTextView,
      dividerView,
      completeButton
    ])
    
    // saveButton
    saveButton.isHidden = false
    
    // nameLabel
    textLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16)
    
    // nameTextField
    textTextField.anchor(top: textLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16, heightConstant: 40.superAdjusted)
    
    // kindOfTaskLabel
    kindOfTaskLabel.anchor(top: textTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16)
    
    // kindsOfTaskButton
    kindsOfTaskButton.centerYAnchor.constraint(equalTo: kindOfTaskLabel.centerYAnchor).isActive = true
    kindsOfTaskButton.anchor(right: view.rightAnchor, rightConstant: 16)
    
    // collectionView
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.register(KindOfTaskCell.self, forCellWithReuseIdentifier: KindOfTaskCell.reuseID)
    collectionView.anchor(top: kindOfTaskLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, heightConstant: 100.superAdjusted )
    
    // descriptionLabel
    descriptionLabel.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16)
    
    // plannedDateButton
    plannedDateButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor).isActive = true
    plannedDateButton.anchor(right: view.rightAnchor, rightConstant: 16, widthConstant: 100, heightConstant: 40)
    
    // descriptionTextView
    descriptionTextView.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor,  right: view.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 16.superAdjusted, rightConstant: 16, heightConstant: 100)
    
    // dividerView
    dividerView.anchor(left: descriptionTextView.leftAnchor, bottom: descriptionTextView.bottomAnchor, right: descriptionTextView.rightAnchor,  heightConstant: 1.0)
    
    // completeTaskButton
    completeButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,  leftConstant: 16, bottomConstant: 16, rightConstant: 16, heightConstant: 48.superAdjusted)

  }
  
  private func configureAlert() {
    
    // adding
    view.addSubviews([
      alertBackgroundView,
      alertAnimationView,
      alertDatePicker,
      alertDatePickerOkButton,
      alertDatePickerCancelButton
    ])
    
    alertAnimationView.addSubview(alertOkButton)
    
    // alertView
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // alertAnimationView
    alertAnimationView.anchorCenterXToSuperview()
    alertAnimationView.anchorCenterYToSuperview()
    
    // alertDatePicker
    alertDatePicker.anchorCenterXToSuperview()
    alertDatePicker.anchorCenterYToSuperview()
    
    // alertDatePickerOkButton
    alertDatePickerOkButton.anchor(top: alertDatePicker.bottomAnchor, right: alertDatePicker.rightAnchor, topConstant: 8, widthConstant: alertDatePicker.bounds.width / 2 - 8, heightConstant: 50)
    
    // alertDatePickerCancelButton
    alertDatePickerCancelButton.anchor(top: alertDatePicker.bottomAnchor, left: alertDatePicker.leftAnchor, topConstant: 8, widthConstant: alertDatePicker.bounds.width / 2 - 8, heightConstant: 50)
    
    // alertButton
    alertOkButton.anchor(top: completeButton.topAnchor, left: completeButton.leftAnchor, bottom: completeButton.bottomAnchor, right: completeButton.rightAnchor)
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
      completeButtonClickTrigger: completeButton.rx.tap.asDriver(),
      configureTaskTypesButtonClickTrigger: kindsOfTaskButton.rx.tap.asDriver(),
      datePickerButtonClickTrigger: plannedDateButton.rx.tap.asDriver(),
      saveTaskButtonClickTrigger: saveButton.rx.tap.asDriver(),
      // Complete Task Alert
      alertOkButtonClickTrigger: alertOkButton.rx.tap.asDriver(),
      // datePicker
      alertDatePickerCancelButtonClick: alertDatePickerCancelButton.rx.tap.asDriver(),
      alertDatePickerDate: alertDatePicker.rx.date.asDriver(),
      alertDatePickerOKButtonClick: alertDatePickerOkButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.clearDescriptionPlaceholder.drive(clearDescriptionPlaceholderBinder),
      outputs.configureKindsOfTask.drive(),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.datePickerDate.drive(alertDatePicker.rx.date),
      outputs.descriptionTextField.drive(descriptionTextView.rx.text),
      outputs.navigateBack.drive(),
      outputs.save.drive(),
      outputs.setDescriptionPlaceholder.drive(setDescriptionPlaceholderBinder),
      outputs.showComleteAlertTrigger.drive(showComleteAlertTriggerBinder),
      outputs.showDatePickerAlertTrigger.drive(showDatePickerAlertTriggerBinder),
      outputs.hideAlertTrigger.drive(hideAlertBinder),
      outputs.plannedText.drive(plannedButtonTextBinder),
      outputs.taskIsNewTrigger.drive(taskIsNewBinder),
      outputs.taskIsNotNewTrigger.drive(taskIsNotNewBinder),
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
  
  var showComleteAlertTriggerBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      let texts = ["Да, я молодец!","Просто герой :)","Красавчик же","Светлое будущее приближается :)"]
      
      // alertView
      vc.alertBackgroundView.isHidden = false
      
      // alertAnimationView
      vc.alertAnimationView.isHidden = false
      vc.alertAnimationView.animation = Animation.named("taskDone1")
      vc.alertAnimationView.removeAllConstraints()
      vc.alertAnimationView.anchor(top: vc.view.topAnchor, left: vc.view.leftAnchor, bottom: vc.view.bottomAnchor, right: vc.view.rightAnchor)
      vc.alertAnimationView.play()
      
      // alertButton
      vc.alertOkButton.isHidden = false
      vc.alertOkButton.setTitle(texts.randomElement(), for: .normal)
    })
  }
  
  var showDatePickerAlertTriggerBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in

      // alertView
      vc.alertBackgroundView.isHidden = false
      vc.alertDatePicker.isHidden = false
      vc.alertDatePickerOkButton.isHidden = false
      vc.alertDatePickerCancelButton.isHidden = false
      vc.dismissKeyboard()
    })
  }
  
  
  var plannedButtonTextBinder: Binder<String> {
    return Binder(self, binding: { (vc, text) in
      vc.plannedDateButton.setTitle(text, for: .normal)
    })
  }
  
  
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertAnimationView.isHidden = true
      vc.alertBackgroundView.isHidden = true
      vc.alertDatePicker.isHidden = true
      vc.alertDatePickerOkButton.isHidden = true
      vc.alertDatePickerCancelButton.isHidden = true
    })
  }
  
  var taskIsNewBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
        vc.completeButton.isHidden = true
        vc.textTextField.becomeFirstResponder()
    })
  }
  
  var taskIsNotNewBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
        vc.completeButton.isHidden = false
        vc.hideKeyboardWhenTappedAround()
    })
  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskSection>(
      configureCell: {(_, collectionView, indexPath, item) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KindOfTaskCell.reuseID, for: indexPath) as! KindOfTaskCell
        cell.configure(kindOfTask: item.kindOfTask, isSelected: item.isSelected)
        return cell
      })
  }
}
