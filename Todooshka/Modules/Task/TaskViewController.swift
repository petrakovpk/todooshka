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

enum BottomButtonsMode {
  case create
  case complete
  case publish
}

class TaskViewController: TDViewController {
  public var viewModel: TaskViewModel!
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Elements 
  private let taskTitleTextField: TDTaskTextField = {
    let textField = TDTaskTextField(placeholder: "Введите название задачи")
    let spacer = UIView()
    textField.returnKeyType = .done
    textField.rightView = spacer
    textField.rightViewMode = .always
    spacer.anchor(
      widthConstant: Sizes.TextFields.TDTaskTextField.heightConstant,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant)
    return textField
  }()
  
  private let taskTitleSaveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.tickSquare.image.template, for: .normal)
    button.tintColor = .black
    return button
  }()
  
  private let taskDescriptionInputView: PlaceholderTextView = {
    let textView = PlaceholderTextView()
    textView.borderWidth = 0
    textView.backgroundColor = .clear
    textView.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    textView.placeholder = "Напишите комментарий"
    return textView
  }()
  
  private let taskDescriptionSaveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.tickSquare.image.template, for: .normal)
    button.tintColor = .black
    return button
  }()
  
  // MARK: - UI Elements - EXPECTED DATETIME
  private let expectedDateTimelabel: UILabel = {
    let label = UILabel(text: "Срок")
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textAlignment = .left
    label.layer.zPosition = 2
    return label
  }()
  
  private let expectedDateButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = UIColor(hexString: "#F4F5FF")
    button.borderWidth = 1.0
    button.borderColor = UIColor(hexString: "#CCCEFF")
    button.setTitle("24 нояб.", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    button.layer.zPosition = 2
    return button
  }()
  
  private let expectedTimeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = UIColor(hexString: "#F4F5FF")
    button.borderWidth = 1.0
    button.borderColor = UIColor(hexString: "#CCCEFF")
    button.setTitleColor(Style.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    button.layer.zPosition = 2
    return button
  }()
  
  private let expectedDateTimeBackground: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    view.layer.zPosition = 2
    return view
  }()
  
  private let expectedDatePicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.datePickerMode = .date
    picker.preferredDatePickerStyle = .inline
    picker.backgroundColor = Style.App.background
    picker.cornerRadius = 8
    picker.isHidden = true
    picker.locale = Locale(identifier: "ru_RU")
    picker.layer.zPosition = 2
    return picker
  }()
  
  private let expectedDatePickerTodayButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = Style.App.background
    button.setTitle("Сегодня", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.isHidden = true
    button.layer.zPosition = 2
    return button
  }()
  
  private let expectedDatePickerOkButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = Palette.SingleColors.Portage
    button.setTitle("OK", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.isHidden = true
    button.layer.zPosition = 2
    return button
  }()
  
  private let expectedTimePicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.datePickerMode = .time
    picker.preferredDatePickerStyle = .wheels
    picker.minuteInterval = 5
    picker.backgroundColor = Style.App.background
    picker.cornerRadius = 8
    picker.isHidden = true
    picker.locale = Locale(identifier: "ru_RU")
    picker.layer.zPosition = 2
    return picker
  }()
  
  private let expectedTimePickerClearButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = Style.App.background
    button.setTitle("В течении дня", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.isHidden = true
    button.layer.zPosition = 2
    return button
  }()
  
  private let expectedTimePickerOkButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = Palette.SingleColors.Portage
    button.setTitle("OK", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.isHidden = true
    button.layer.zPosition = 2
    return button
  }()
  
  // MARK: - UI Elements - KINDS OF TASK
  private let kindOfTaskLabel: UILabel = {
    let label = UILabel(text: "Тип")
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textAlignment = .left
    return label
  }()
  
  private let kindOfTaskSettingsButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.settingsGear.image.template, for: .normal)
    button.tintColor = Style.Buttons.RoundButton.tint
    return button
  }()
  
  private var kindCollectionView: UICollectionView!
  private var kindDataSource: RxCollectionViewSectionedAnimatedDataSource<KindSection>!
  
  // MARK: - UI Elements - DESCRIPTION
  private let descriptionLabel: UILabel = {
    let label = UILabel(text: "Комментарий")
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textAlignment = .left
    return label
  }()

  private let dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.094, green: 0.105, blue: 0.233, alpha: 1)
    return view
  }()
  
  // MARK: - UI Elements - BOTTOM BUTTONS
  private let bottomButtonsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    return stackView
  }()
  
  private let createButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.setTitle("Создать!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    return button
  }()
  
  private let completeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.setTitle("Выполнено!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    return button
  }()
  
  private let closeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.setTitle("Зарыть!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(hexString: "#D6D7EC")
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    button.isHidden = true
    return button
  }()
  
  private let publishButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.setTitle("Опубликовать!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.PurpleHeart
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    return button
  }()

  // MARK: - UI Elements - Animation
  private let animationView: AnimationView = {
    let animationView = AnimationView(name: "taskDone1")
    animationView.contentMode = .scaleAspectFill
    animationView.loopMode = .repeat(1.0)
    animationView.animationSpeed = 1.0
    animationView.isUserInteractionEnabled = false
    return animationView
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  private func configureUI() {
    setupCollectionView()
    setupHeader()
    setupSubviews()
    setupConstraints()
  }
  
  private func setupCollectionView() {
    kindCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    kindCollectionView.backgroundColor = UIColor.clear
    kindCollectionView.clipsToBounds = false
    kindCollectionView.isScrollEnabled = false
    kindCollectionView.register(KindCell.self, forCellWithReuseIdentifier: KindCell.reuseID)
  }
  
  private func setupHeader() {
    titleLabel.text = "Задача"
    backButton.isHidden = false
  }
  
  private func setupSubviews() {
    view.addSubviews([
      taskTitleTextField,
      taskTitleSaveButton,
      expectedDateTimelabel,
      expectedDateButton,
      expectedTimeButton,
      kindOfTaskLabel,
      kindOfTaskSettingsButton,
      kindCollectionView,
      descriptionLabel,
      taskDescriptionInputView,
      taskDescriptionSaveButton,
      dividerView,
      bottomButtonsStackView,
      animationView,
      expectedDateTimeBackground,
      expectedDatePicker,
      expectedDatePickerTodayButton,
      expectedDatePickerOkButton,
      expectedTimePicker,
      expectedTimePickerClearButton,
      expectedTimePickerOkButton
    ])
    
    bottomButtonsStackView.addArrangedSubviews([
      createButton,
      closeButton,
      publishButton,
      completeButton
    ])
  }
  
  private func setupConstraints() {
    taskTitleTextField.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant
    )
    
    taskTitleSaveButton.centerYAnchor.constraint(equalTo: taskTitleTextField.centerYAnchor).isActive = true
    taskTitleSaveButton.anchor(
      right: taskTitleTextField.rightAnchor,
      widthConstant: 24,
      heightConstant: 24
    )
    
    expectedDateTimelabel.anchor(
      top: taskTitleTextField.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )
    
    expectedDateButton.anchor(
      top: expectedDateTimelabel.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16,
      widthConstant: 87,
      heightConstant: 42
    )
    
    expectedTimeButton.anchor(
      top: expectedDateTimelabel.bottomAnchor,
      left: expectedDateButton.rightAnchor,
      topConstant: 8,
      leftConstant: 8,
      widthConstant: 87,
      heightConstant: 42
    )
    
    expectedDateTimeBackground.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor
    )
    
    expectedDatePicker.anchorCenterXToSuperview()
    expectedDatePicker.anchorCenterYToSuperview()
    
    expectedDatePickerTodayButton.anchor(
      top: expectedDatePicker.bottomAnchor,
      left: expectedDatePicker.leftAnchor,
      topConstant: 8,
      widthConstant: expectedDatePicker.bounds.width / 2 - 4,
      heightConstant: 40
    )
    
    expectedDatePickerOkButton.anchor(
      top: expectedDatePicker.bottomAnchor,
      right: expectedDatePicker.rightAnchor,
      topConstant: 8,
      widthConstant: expectedDatePicker.bounds.width / 2 - 4,
      heightConstant: 40
    )
    
    expectedTimePicker.anchorCenterXToSuperview()
    expectedTimePicker.anchorCenterYToSuperview()
    
    expectedTimePickerClearButton.anchor(
      top: expectedTimePicker.bottomAnchor,
      left: expectedTimePicker.leftAnchor,
      topConstant: 8,
      widthConstant: expectedTimePicker.bounds.width / 2 - 4,
      heightConstant: 40
    )
    
    expectedTimePickerOkButton.anchor(
      top: expectedTimePicker.bottomAnchor,
      right: expectedTimePicker.rightAnchor,
      topConstant: 8,
      widthConstant: expectedTimePicker.bounds.width / 2 - 4,
      heightConstant: 40
    )
    
    kindOfTaskLabel.anchor(
      top: expectedDateButton.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )
    
    kindOfTaskSettingsButton.centerYAnchor.constraint(equalTo: kindOfTaskLabel.centerYAnchor).isActive = true
    kindOfTaskSettingsButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16
    )
    
    kindCollectionView.anchor(
      top: kindOfTaskLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      heightConstant: Sizes.Views.KindsOfTaskCollectionView.height
    )
    
    descriptionLabel.anchor(
      top: kindCollectionView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    taskDescriptionSaveButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor).isActive = true
    taskDescriptionSaveButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16,
      widthConstant: 24,
      heightConstant: 24
    )
    
    taskDescriptionInputView.anchor(
      top: descriptionLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 12,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextViews.TaskDescriptionTextView.height
    )
    
    dividerView.anchor(
      left: taskDescriptionInputView.leftAnchor,
      bottom: taskDescriptionInputView.bottomAnchor,
      right: taskDescriptionInputView.rightAnchor,
      heightConstant: 1.0
    )
    
    bottomButtonsStackView.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 8,
      heightConstant: Sizes.Buttons.AppButton.height
    )
    
    animationView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor
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
      widthDimension: .absolute(Sizes.Cells.KindCell.width),
      heightDimension: .absolute(Sizes.Cells.KindCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(Sizes.Cells.KindCell.width),
      heightDimension: .estimated(Sizes.Cells.KindCell.height))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  // MARK: - Bind
  func bindViewModel() {
    let task = viewModel.task.value
    taskTitleTextField.insertText(task.text)
    taskDescriptionInputView.insertText(task.description)
    expectedDatePicker.date = task.planned
    expectedTimePicker.date = task.planned
    expectedDateButton.setTitle(DateFormatter.midDateFormatter.string(for: task.planned), for: .normal)
    expectedTimeButton.setTitle(DateFormatter.midTimeFormatter.string(for: task.planned), for: .normal)
    
    let input = TaskViewModel.Input(
      // text
      taskTextField: taskTitleTextField.rx.text.orEmpty.asDriver(),
      taskTextFieldEditingDidEndOnExit: taskTitleTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      taskTextSaveButtonClickTrigger: taskTitleSaveButton.rx.tap.asDriver(),
      // description
      taskDescriptionTextView: taskDescriptionInputView.rx.text.orEmpty.asDriver(),
      taskDescriptionSaveButtonClickTrigger: taskDescriptionSaveButton.rx.tap.asDriver(),
      // kind
      kindOfTaskSettingsButtonClickTrigger: kindOfTaskSettingsButton.rx.tap.asDriver(),
      kindOfTaskSelection: kindCollectionView.rx.itemSelected.asDriver(),
      // expected date
      expectedDateSelected: expectedDatePicker.rx.date.asDriver(),
      expectedDateButtonClickTrigger: expectedDateButton.rx.tap.asDriver(),
      expectedDatePickerTodayButtonClickTrigger: expectedDatePickerTodayButton.rx.tap.asDriver() ,
      expectedDatePickerOkButtonClickTrigger: expectedDatePickerOkButton.rx.tap.asDriver(),
      expectedDatePickerBackgroundClickTrigger: expectedDateTimeBackground.rx.tapGesture().when(.recognized)
        .asLocation().filter { !self.expectedDatePicker.frame.contains($0) }.mapToVoid().asDriverOnErrorJustComplete(),
      // expected time
      expectedTimeSelected: expectedTimePicker.rx.date.asDriver(),
      expectedTimeButtonClickTrigger: expectedTimeButton.rx.tap.asDriver(),
      expectedTimePickerClearButtonClickTrigger: expectedTimePickerClearButton.rx.tap.asDriver() ,
      expectedTimePickerOkButtonClickTrigger: expectedTimePickerOkButton.rx.tap.asDriver(),
      expectedTimePickerBackgroundClickTrigger: expectedDateTimeBackground.rx.tapGesture().when(.recognized)
        .asLocation().filter { !self.expectedTimePicker.frame.contains($0) }.mapToVoid().asDriverOnErrorJustComplete(),
      // bottom buttons
      createButtonClickTrigger: createButton.rx.tap.asDriver(),
      completeButtonClickTrigger: completeButton.rx.tap.asDriver(),
      // headre buttons
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      // text
      outputs.taskTextSaveButtonIsHidden.drive(taskTitleSaveButton.rx.isHidden),
      // description
      outputs.taskDescriptionSaveButtonIsHidden.drive(taskDescriptionSaveButton.rx.isHidden),
      // kinds
      outputs.kindSections.drive(kindCollectionView.rx.items(dataSource: kindDataSource)),
      outputs.kindOpenSettings.drive(),
      // expected date and expected time
      outputs.expectedDateTime.drive(expectedDateTimeBinder),
      // expected date
      outputs.expectedDatePickerOpen.drive(expectedDatePickerOpenBinder),
      outputs.expectedDatePickerClose.drive(expectedDatePickerCloseBinder),
      outputs.expectedDatePickerScrollToToday.drive(expectedDatePickerScrollToTodayBinder),
      // expoected time
      outputs.expectedTimePickerOpen.drive(expectedTimePickerOpenBinder),
      outputs.expectedTimePickerClose.drive(expectedTimePickerCloseBinder),
      outputs.expectedTimePickerScrollToEndOfDay.drive(expectedTimePickerScrollToEndOfDayBinder),
      // bottom buttons
      outputs.bottomButtonsMode.drive(bottomButtonsModeBinder),
      // save
      outputs.taskSave.drive(),
      // close
      outputs.close.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - INIT BINDERS
  var taskIsNewBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isNew in
      if isNew {
        vc.taskTitleTextField.becomeFirstResponder()
      } else {
        vc.hideKeyboardWhenTappedAround()
      }
    })
  }
  
  var isModalBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isModal in
      if isModal {
        vc.backButton.isHidden = true
      } else {
        vc.backButton.isHidden = false
      }
    })
  }

  // MARK: - BINDERS - Expected date and expected time
  var expectedDateTimeBinder: Binder<Date> {
    return Binder(self, binding: { vc, expectedDate in
      vc.expectedDateButton.setTitle(DateFormatter.midDateFormatter.string(for: expectedDate), for: .normal)
      vc.expectedTimeButton.setTitle(DateFormatter.midTimeFormatter.string(for: expectedDate), for: .normal)
    })
  }
  
  // MARK: - BINDERS - Expected date
  var expectedDatePickerOpenBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.expectedDateTimeBackground.isHidden = false
      vc.expectedDatePicker.isHidden = false
      vc.expectedDatePickerOkButton.isHidden = false
      vc.expectedDatePickerTodayButton.isHidden = false
      vc.dismissKeyboard()
    })
  }
  
  var expectedDatePickerCloseBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.expectedDateTimeBackground.isHidden = true
      vc.expectedDatePicker.isHidden = true
      vc.expectedDatePickerOkButton.isHidden = true
      vc.expectedDatePickerTodayButton.isHidden = true
    })
  }
  
  var expectedDatePickerScrollToTodayBinder: Binder<Date> {
    return Binder(self, binding: { vc, date in
      vc.expectedDatePicker.setDate(date, animated: true)
    })
  }
  
  // MARK: - BINDERS - Expected time
  var expectedTimePickerOpenBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.expectedDateTimeBackground.isHidden = false
      vc.expectedTimePicker.isHidden = false
      vc.expectedTimePickerOkButton.isHidden = false
      vc.expectedTimePickerClearButton.isHidden = false
      vc.dismissKeyboard()
    })
  }
  
  var expectedTimePickerCloseBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.expectedDateTimeBackground.isHidden = true
      vc.expectedTimePicker.isHidden = true
      vc.expectedTimePickerOkButton.isHidden = true
      vc.expectedTimePickerClearButton.isHidden = true
    })
  }

  var expectedTimePickerScrollToEndOfDayBinder: Binder<Date> {
    return Binder(self, binding: { vc, date in
      vc.expectedTimePicker.setDate(date, animated: true)
    })
  }
  
  // MARK: - BINDERS - Bottom buttons
  var bottomButtonsModeBinder: Binder<BottomButtonsMode> {
    return Binder(self, binding: { vc, mode in
      switch mode {
      case .create:
        vc.createButton.isHidden = false
        vc.completeButton.isHidden = true
        vc.publishButton.isHidden = true
      case .complete:
        vc.createButton.isHidden = true
        vc.completeButton.isHidden = false
        vc.publishButton.isHidden = true
      case .publish:
        vc.createButton.isHidden = true
        vc.completeButton.isHidden = true
        vc.publishButton.isHidden = false
      }
    })
  }
  // MARK: - BINDERS - Animation
  var playAnimationViewBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.animationView.play()
    })
  }

  // MARK: - Configure Data Source
  func configureDataSource() {
    kindCollectionView.dataSource = nil
    kindDataSource = RxCollectionViewSectionedAnimatedDataSource<KindSection>(
      configureCell: {_, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KindCell.reuseID, for: indexPath) as! KindCell
        cell.configure(with: item)
        return cell
      })
  }
}


