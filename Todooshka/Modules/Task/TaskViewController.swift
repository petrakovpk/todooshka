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

  // MARK: - UI Elements
  private let nameTextField: TDTaskTextField = {
    let field = TDTaskTextField(placeholder: "Введите название задачи")
    field.returnKeyType = .done
    return field
  }()

  private let kindOfTaskLabel: UILabel = {
    let label = UILabel(text: "Тип")
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label.textAlignment = .left
    return label
  }()

  private let kindsOfTaskButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.settingsGear.image.template, for: .normal)
    button.tintColor = Style.Buttons.RoundButton.tint
    return button
  }()

  private let plannedDateButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(Style.App.text, for: .normal)
    button.cornerRadius = 15
    button.borderWidth = 1.0
    button.borderColor = Style.Cells.KindOfTask.Border
    return button
  }()

  private var collectionView: UICollectionView!

  private let descriptionLabel: UILabel = {
    let label = UILabel(text: "Комментарий")
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label.textAlignment = .left
    return label
  }()

  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.borderWidth = 0
    textView.backgroundColor = .clear
    textView.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    return textView
  }()

  private let dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.094, green: 0.105, blue: 0.233, alpha: 1)
    return view
  }()

  private let completeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 48 / 2
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
    button.cornerRadius = Sizes.Buttons.AlertOkButton.height / 2
    button.setTitle("Да, я молодец :)", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Style.Buttons.AlertRoseButton.Background
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
    picker.backgroundColor = Style.App.background
    picker.cornerRadius = 15
    picker.isHidden = true
    picker.locale = Locale(identifier: "ru_RU")
    return picker
  }()

  private let alertDatePickerOkButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 12
    button.setTitle("Выбрать", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.backgroundColor = Palette.SingleColors.Portage
    button.isHidden = true
    return button
  }()

  private let alertDatePickerCancelButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 12
    button.setTitle("Отмена", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.backgroundColor = Style.App.background
    button.isHidden = true
    return button
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  private func configureUI() {
    // header
    saveButton.isHidden = false
    titleLabel.text = "Задача"

    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())

    // adding
    view.addSubviews([
      nameTextField,
      kindOfTaskLabel,
      kindsOfTaskButton,
      collectionView,
      plannedDateButton,
      descriptionLabel,
      descriptionTextView,
      dividerView,
      completeButton
    ])
    
    // nameTextField
    nameTextField.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant
    )

    // kindOfTaskLabel
    kindOfTaskLabel.anchor(
      top: nameTextField.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 12,
      leftConstant: 16,
      rightConstant: 16
    )

    // kindsOfTaskButton
    kindsOfTaskButton.centerYAnchor.constraint(equalTo: kindOfTaskLabel.centerYAnchor).isActive = true
    kindsOfTaskButton.anchor(right: view.rightAnchor, rightConstant: 16)

    // collectionView
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.register(KindOfTaskCell.self, forCellWithReuseIdentifier: KindOfTaskCell.reuseID)
    collectionView.anchor(
      top: kindOfTaskLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 12,
      leftConstant: 16,
      heightConstant: Sizes.Views.KindsOfTaskCollectionView.height
    )

    // descriptionLabel
    descriptionLabel.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16)

    // plannedDateButton
    plannedDateButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor, constant: 6).isActive = true
    plannedDateButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16,
      widthConstant: Sizes.Buttons.PlanedButton.width,
      heightConstant: Sizes.Buttons.PlanedButton.height
    )

    // descriptionTextView
    descriptionTextView.anchor(
      top: descriptionLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 12,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextViews.TaskDescriptionTextView.height
    )

    // dividerView
    dividerView.anchor(
      left: descriptionTextView.leftAnchor,
      bottom: descriptionTextView.bottomAnchor,
      right: descriptionTextView.rightAnchor,
      heightConstant: 1.0
    )

    // completeTaskButton
    completeButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.Buttons.AppButton.height
    )
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
    alertDatePickerOkButton.anchor(
      top: alertDatePicker.bottomAnchor,
      right: alertDatePicker.rightAnchor,
      topConstant: 8,
      widthConstant: alertDatePicker.bounds.width / 2 - 8,
      heightConstant: 50
    )

    // alertDatePickerCancelButton
    alertDatePickerCancelButton.anchor(
      top: alertDatePicker.bottomAnchor,
      left: alertDatePicker.leftAnchor,
      topConstant: 8,
      widthConstant: alertDatePicker.bounds.width / 2 - 8,
      heightConstant: 50
    )

    // alertButton
    alertOkButton.anchor(
      top: completeButton.topAnchor,
      left: completeButton.leftAnchor,
      bottom: completeButton.bottomAnchor,
      right: completeButton.rightAnchor
    )
  }

  // MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(Sizes.Cells.KindOfTaskCell.width),
      heightDimension: .absolute(Sizes.Cells.KindOfTaskCell.height)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(Sizes.Cells.KindOfTaskCell.width),
      heightDimension: .estimated(Sizes.Cells.KindOfTaskCell.height)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }

  // MARK: - Bind
  func bindViewModel() {
    let input = TaskViewModel.Input(
      // alert complete
      alertOkButtonClickTrigger: alertOkButton.rx.tap.asDriver(),
      // alertDatePicker
      alertDatePickerDate: alertDatePicker.rx.date.asDriver(),
      alertDatePickerOKButtonClick: alertDatePickerOkButton.rx.tap.asDriver(),
      alertDatePickerCancelButtonClick: alertDatePickerCancelButton.rx.tap.asDriver(),
      // complete button
      completeButtonClickTrigger: completeButton.rx.tap.asDriver(),
      // configure kindsOfTask button
      configureTaskTypesButtonClickTrigger: kindsOfTaskButton.rx.tap.asDriver(),
      // collectionView
      selection: collectionView.rx.itemSelected.asDriver(),
      // datePickerButton
      datePickerButtonClickTrigger: plannedDateButton.rx.tap.asDriver(),
      // descriptionTextField
      descriptionTextView: descriptionTextView.rx.text.orEmpty.asDriver(),
      descriptionTextViewDidBeginEditing: descriptionTextView.rx.didBeginEditing.asDriver(),
      descriptionTextViewDidEndEditing: descriptionTextView.rx.didEndEditing.asDriver(),
      // header buttons
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      saveTaskButtonClickTrigger: saveButton.rx.tap.asDriver(),
      // nameTextField
      nameTextField: nameTextField.rx.text.orEmpty.asDriver(),
      nameTextFieldEditingDidEndOnExit: nameTextField.rx.controlEvent(.editingDidEndOnExit).asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      // alert complete
      outputs.showComleteAlertTrigger.drive(showComleteAlertTriggerBinder),
      // alertDatePicker
      outputs.datePickerDate.drive(alertDatePicker.rx.date),
      outputs.hideAlertTrigger.drive(hideAlertBinder),
      outputs.plannedText.drive(plannedButtonTextBinder),
      outputs.showDatePickerAlertTrigger.drive(showDatePickerAlertTriggerBinder),
      // complete button
      outputs.completeButtonIsHidden.drive(completeButton.rx.isHidden),
      // collectionView
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.descriptionTextField.drive(descriptionTextView.rx.text),
      // descriptionTextVIew
      outputs.hideDescriptionPlaceholder.drive(hideDescriptionPlaceholderBinder),
      outputs.showDescriptionPlaceholder.drive(showDescriptionPlaceholderBinder),
      // header buttons
      outputs.navigateBack.drive(),
      outputs.save.drive(),
      // nameTextField
      outputs.nameTextField.drive(nameTextField.rx.text),
      // open kindsOfTask list
      outputs.openKindsOfTaskList.drive(),
      // task
      outputs.taskIsNew.drive(taskIsNewBinder),
      // yandex
      outputs.yandexMetrika.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }

  // MARK: - Binders
  var hideCompleteButtonBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.completeButton.isHidden = true
    })
  }

  var hideDescriptionPlaceholderBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.descriptionTextView.textColor = Style.App.text
      vc.descriptionTextView.clear()
    })
  }

  var showDescriptionPlaceholderBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.descriptionTextView.textColor = Style.App.placeholder
      vc.descriptionTextView.text = "Напишите комментарий"
    })
  }

  var showComleteAlertTriggerBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      let texts = ["Да, я молодец!", "Просто герой :)", "Красавчик же", "Светлое будущее приближается :)"]

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
    return Binder(self, binding: { vc, _ in
      // alertView
      vc.alertBackgroundView.isHidden = false
      vc.alertDatePicker.isHidden = false
      vc.alertDatePickerOkButton.isHidden = false
      vc.alertDatePickerCancelButton.isHidden = false
      vc.dismissKeyboard()
    })
  }

  var plannedButtonTextBinder: Binder<String> {
    return Binder(self, binding: { vc, text in
      vc.plannedDateButton.setTitle(text, for: .normal)
    })
  }

  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertAnimationView.isHidden = true
      vc.alertBackgroundView.isHidden = true
      vc.alertDatePicker.isHidden = true
      vc.alertDatePickerOkButton.isHidden = true
      vc.alertDatePickerCancelButton.isHidden = true
    })
  }

  var taskIsNewBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isNew in
      if isNew {
        vc.nameTextField.becomeFirstResponder()
      } else {
        vc.backButton.isHidden = false
        vc.hideKeyboardWhenTappedAround()
      }
    })
  }


  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskSection>(
      configureCell: {_, collectionView, indexPath, item in
        guard  let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: KindOfTaskCell.reuseID,
          for: indexPath
        ) as? KindOfTaskCell else { return UICollectionViewCell() }
        cell.configure(kindOfTask: item.kindOfTask, isSelected: item.isSelected)
        return cell
      })
  }
}
