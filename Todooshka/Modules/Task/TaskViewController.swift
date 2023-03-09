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
import YPImagePicker

enum BottomButtonsMode {
  case create
  case complete
  case publish
  case unpublish
}

class TaskViewController: TDViewController {
  public var viewModel: TaskViewModel!
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Elements - NAME
  private let nameTextField: TDTaskTextField = {
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
  
  private let saveNameTextFieldButton: UIButton = {
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
    return button
  }()
  
  private let expectedTimeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = UIColor(hexString: "#F4F5FF")
    button.borderWidth = 1.0
    button.borderColor = UIColor(hexString: "#CCCEFF")
    button.setTitle("17:00", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return button
  }()
  
  private let expectedDateTimeBackground: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
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
    return picker
  }()
  
  private let expectedDatePickerClearButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = Style.App.background
    button.setTitle("Сегодня", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.isHidden = true
    return button
  }()
  
  private let expectedDatePickerOkButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = Palette.SingleColors.Portage
    button.setTitle("OK", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.isHidden = true
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
    return picker
  }()
  
  private let expectedTimePickerClearButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = Style.App.background
    button.setTitle("В течении дня", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.isHidden = true
    return button
  }()
  
  private let expectedTimePickerOkButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = Palette.SingleColors.Portage
    button.setTitle("OK", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.isHidden = true
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
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskSection>!
  
  // MARK: - UI Elements - DESCRIPTION
  private let descriptionLabel: UILabel = {
    let label = UILabel(text: "Комментарий")
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
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
  
  private let saveDescriptionTextViewButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.tickSquare.image.template, for: .normal)
    button.tintColor = .black
    return button
  }()
  
  private let dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.094, green: 0.105, blue: 0.233, alpha: 1)
    return view
  }()
  
  // MARK: - UI Elements - RESULT
  private let resultPhotoLabel: UILabel = {
    let label = UILabel(text: "Фото результата:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textAlignment = .left
    return label
  }()
  
  private let resultImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .white
    imageView.contentMode = .scaleToFill
    imageView.cornerRadius = 8
    imageView.clipsToBounds = true
    return imageView
  }()
  
  // MARK: - UI Elements - BOTTOM BUTTONS
  private let bottomButtonsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    return stackView
  }()
  
  private let saveTaskButton: UIButton = {
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
  
  private let getPhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.backgroundColor = UIColor(hexString: "#C66DF1")
    button.setImage(Icon.camera.image.template, for: .normal)
    button.tintColor = .white
    return button
  }()
  
  private let closeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.setTitle("Зарыть!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(hexString: "#D6D7EC")
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    return button
  }()
  
  private let publishButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.setTitle("Опубликовать!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    return button
  }()
  
  private let unpublishButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.setTitle("Снять с публикации.", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.BlueRibbon
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
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    titleLabel.text = "Задача"
    
    // adding 1 order
    view.addSubviews([
      nameTextField,
      saveNameTextFieldButton,
      expectedDateTimelabel,
      expectedDateButton,
      expectedTimeButton,
      kindOfTaskLabel,
      kindOfTaskSettingsButton,
      collectionView,
      descriptionLabel,
      descriptionTextView,
      saveDescriptionTextViewButton,
      dividerView,
      resultPhotoLabel,
      resultImageView,
      bottomButtonsStackView,
      animationView
    ])
    
    // adding 2 order
    view.addSubviews([
      expectedDateTimeBackground
    ])
    
    // adding 3 order
    view.addSubviews([
      expectedDatePicker,
      expectedDatePickerClearButton,
      expectedDatePickerOkButton,
      expectedTimePicker,
      expectedTimePickerClearButton,
      expectedTimePickerOkButton
    ])
    
    nameTextField.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant
    )
    
    saveNameTextFieldButton.centerYAnchor.constraint(equalTo: nameTextField.centerYAnchor).isActive = true
    saveNameTextFieldButton.anchor(
      right: nameTextField.rightAnchor,
      widthConstant: 24,
      heightConstant: 24
    )
    
    expectedDateTimelabel.anchor(
      top: nameTextField.bottomAnchor,
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
    
    expectedDatePickerClearButton.anchor(
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
    
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.register(KindOfTaskCell.self, forCellWithReuseIdentifier: KindOfTaskCell.reuseID)
    collectionView.anchor(
      top: kindOfTaskLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      heightConstant: Sizes.Views.KindsOfTaskCollectionView.height
    )
    
    descriptionLabel.anchor(
      top: collectionView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    saveDescriptionTextViewButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor).isActive = true
    saveDescriptionTextViewButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16,
      widthConstant: 24,
      heightConstant: 24
    )
    
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
    
    dividerView.anchor(
      left: descriptionTextView.leftAnchor,
      bottom: descriptionTextView.bottomAnchor,
      right: descriptionTextView.rightAnchor,
      heightConstant: 1.0
    )
    
    resultPhotoLabel.anchor(
      top: dividerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    resultImageView.anchorCenterXToSuperview()
    resultImageView.anchor(
      top: resultPhotoLabel.bottomAnchor,
      topConstant: 16,
      widthConstant: 100,
      heightConstant: 100
    )
    
    getPhotoButton.anchor(
      widthConstant: Sizes.Buttons.AppButton.height
    )
    
    closeButton.anchor(
      widthConstant: (UIScreen.main.bounds.width - 2 * 16 - Sizes.Buttons.AppButton.height - 8 * 2) / 2
    )
    
    bottomButtonsStackView.addArrangedSubviews([
      saveTaskButton,
      closeButton,
      publishButton,
      unpublishButton,
      completeButton,
      getPhotoButton])
    
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
      right: view.rightAnchor)
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
      heightDimension: .absolute(Sizes.Cells.KindOfTaskCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(Sizes.Cells.KindOfTaskCell.width),
      heightDimension: .estimated(Sizes.Cells.KindOfTaskCell.height))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  // MARK: - Bind
  func bindViewModel() {
    
    let input = TaskViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // nameTextField
      nameTextField: nameTextField.rx.text.orEmpty.asDriver(),
      nameTextFieldEditingDidEndOnExit: nameTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      saveNameTextFieldButtonClickTrigger: saveNameTextFieldButton.rx.tap.asDriver(),
      // expected DateTime
      expectedDateButtonClickTrigger: expectedDateButton.rx.tap.asDriver(),
      expectedDate: expectedDatePicker.rx.date.asDriver(),
      expectedDatePickerClearButtonClickTrigger: expectedDatePickerClearButton.rx.tap.asDriver() ,
      expectedDatePickerOkButtonClickTrigger: expectedDatePickerOkButton.rx.tap.asDriver(),
      expectedDatePickerBackgroundClickTrigger: expectedDateTimeBackground.rx.tapGesture().when(.recognized)
        .asLocation().filter { !self.expectedDatePicker.frame.contains($0) }.mapToVoid().asDriverOnErrorJustComplete(),
      expectedTimeButtonClickTrigger: expectedTimeButton.rx.tap.asDriver(),
      expectedTime: expectedTimePicker.rx.date.asDriver(),
      expectedTimePickerClearButtonClickTrigger: expectedTimePickerClearButton.rx.tap.asDriver() ,
      expectedTimePickerOkButtonClickTrigger: expectedTimePickerOkButton.rx.tap.asDriver(),
      expectedTimePickerBackgroundClickTrigger: expectedDateTimeBackground.rx.tapGesture().when(.recognized)
        .asLocation().filter { !self.expectedTimePicker.frame.contains($0) }.mapToVoid().asDriverOnErrorJustComplete(),
      // kindsOfTask
      kindOfTaskSettingsButtonClickTrigger: kindOfTaskSettingsButton.rx.tap.asDriver(),
      kindOfTaskSelection: collectionView.rx.itemSelected.asDriver(),
      // description
      descriptionTextView: descriptionTextView.rx.text.orEmpty.asDriver(),
      descriptionTextViewDidBeginEditing: descriptionTextView.rx.didBeginEditing.asDriver(),
      descriptionTextViewDidEndEditing: descriptionTextView.rx.didEndEditing.asDriver(),
      saveDescriptionTextViewButtonClickTrigger: saveDescriptionTextViewButton.rx.tap.asDriver(),
      // imageView
      resultImageViewClickTrigger: resultImageView.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      // bottom buttons
      addTaskButtonClickTrigger: saveTaskButton.rx.tap.asDriver(),
      completeButtonClickTrigger: completeButton.rx.tap.asDriver(),
      getPhotoButtonClickTrigger: getPhotoButton.rx.tap.asDriver(),
      closeButtonClickTrigger: closeButton.rx.tap.asDriver(),
      publishButtonClickTrigger: publishButton.rx.tap.asDriver(),
      unpublishButtonClickTrigger: unpublishButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // INIT
      outputs.initData.drive(initDataBinder),
      outputs.taskIsNew.drive(taskIsNewBinder),
      outputs.isModal.drive(isModalBinder),
      // MODE
      outputs.bottomButtonsMode.drive(bottomButtonsModeBinder),
      // BACK
      outputs.navigateBack.drive(),
      // TEXT
      outputs.saveNameTextFieldButtonIsHidden.drive(saveNameTextFieldButton.rx.isHidden),
      outputs.saveText.drive(),
      // EXPECTED
      outputs.expectedDateTime.drive(expectedDateTimeBinder),
      outputs.openExpectedDatePickerTrigger.drive(openExpectedDatePickerTriggerBinder),
      outputs.closeExpectedDatePickerTrigger.drive(closeExpectedDatePickerTriggerBinder),
      outputs.saveExpectedDate.drive(),
      outputs.openExpectedTimePickerTrigger.drive(openExpectedTimePickerTriggerBinder),
      outputs.closeExpectedTimePickerTrigger.drive(closeExpectedTimePickerTriggerBinder),
      outputs.scrollToTodayDatePickerTrigger.drive(scrollToTodayDatePickerTriggerBinder),
      outputs.scrollToEndOfDateTimePickerTrigger.drive(scrollToEndOfDateTimePickerTriggerBinder),
      outputs.saveExpectedTime.drive(),
      // KINDOFTASK
      outputs.openKindOfTaskSettings.drive(),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.selectKindOfTask.drive(),
      // DESCRIPTION
      outputs.hideDescriptionPlaceholder.drive(hideDescriptionPlaceholderBinder),
      outputs.showDescriptionPlaceholder.drive(showDescriptionPlaceholderBinder),
      outputs.saveDescriptionTextViewButtonIsHidden.drive(saveDescriptionTextViewButton.rx.isHidden),
      outputs.saveDescription.drive(),
      // COMPLETE TASK
      outputs.addPhoto.drive(),
      outputs.completeTask.drive(),
      // IMAGE
      outputs.openResultPreview.drive(),
      outputs.image.drive(imageBinder),
      // CLOSE VIEW CONTROLLER
      outputs.dismissViewController.drive(),
      // ADD PHOTO
      outputs.addPhoto.drive(),
      // PUBLISH
      outputs.saveTaskStatus.drive(),
      outputs.publishTask.drive(),
      outputs.publishImage.drive(),
      // ANIMATION
      outputs.playAnimationViewTrigger.drive(playAnimationViewBinder)
      // yandex
      //   outputs.yandexMetrika.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - INIT BINDERS
  var initDataBinder: Binder<Task> {
    return Binder(self, binding: { vc, task in
      vc.nameTextField.insertText(task.text)
      vc.descriptionTextView.insertText(task.description)
      vc.expectedDatePicker.date = task.planned
      vc.expectedTimePicker.date = task.planned
      vc.expectedDateButton.setTitle(DateFormatter.midDateFormatter.string(for: task.planned), for: .normal)
      vc.expectedTimeButton.setTitle(DateFormatter.midTimeFormatter.string(for: task.planned), for: .normal)
    })
  }
  
  var taskIsNewBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isNew in
      if isNew {
        vc.nameTextField.becomeFirstResponder()
        vc.resultPhotoLabel.isHidden = true
        vc.resultImageView.isHidden = true
      } else {
        vc.hideKeyboardWhenTappedAround()
        vc.resultPhotoLabel.isHidden = false
        vc.resultImageView.isHidden = false
      }
    })
  }
  
  // MARK: - OTHER BINDERS
  var bottomButtonsModeBinder: Binder<BottomButtonsMode> {
    return Binder(self, binding: { vc, mode in
      switch mode {
      case .create:
        vc.saveTaskButton.isHidden = false
        vc.completeButton.isHidden = true
        vc.getPhotoButton.isHidden = true
        vc.closeButton.isHidden = true
        vc.publishButton.isHidden = true
        vc.unpublishButton.isHidden = true
      case .complete:
        vc.saveTaskButton.isHidden = true
        vc.completeButton.isHidden = false
        vc.getPhotoButton.isHidden = false
        vc.closeButton.isHidden = true
        vc.publishButton.isHidden = true
        vc.unpublishButton.isHidden = true
      case .publish:
        vc.saveTaskButton.isHidden = true
        vc.completeButton.isHidden = true
        vc.getPhotoButton.isHidden = false
        vc.closeButton.isHidden = false
        vc.publishButton.isHidden = false
        vc.unpublishButton.isHidden = true
      case .unpublish:
        vc.saveTaskButton.isHidden = true
        vc.completeButton.isHidden = true
        vc.getPhotoButton.isHidden = false
        vc.closeButton.isHidden = false
        vc.publishButton.isHidden = true
        vc.unpublishButton.isHidden = false
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
  
  // MARK: - EXPECTED DATETIME BINDERS
  var expectedDateTimeBinder: Binder<Date> {
    return Binder(self, binding: { vc, expectedDate in
      vc.expectedDateButton.setTitle(DateFormatter.midDateFormatter.string(for: expectedDate), for: .normal)
      vc.expectedTimeButton.setTitle(DateFormatter.midTimeFormatter.string(for: expectedDate), for: .normal)
    })
  }
  
  var openExpectedDatePickerTriggerBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.expectedDateTimeBackground.isHidden = false
      vc.expectedDatePicker.isHidden = false
      vc.expectedDatePickerOkButton.isHidden = false
      vc.expectedDatePickerClearButton.isHidden = false
      vc.dismissKeyboard()
    })
  }
  
  var openExpectedTimePickerTriggerBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.expectedDateTimeBackground.isHidden = false
      vc.expectedTimePicker.isHidden = false
      vc.expectedTimePickerOkButton.isHidden = false
      vc.expectedTimePickerClearButton.isHidden = false
      vc.dismissKeyboard()
    })
  }
  
  var scrollToTodayDatePickerTriggerBinder: Binder<Date> {
    return Binder(self, binding: { vc, date in
      vc.expectedDatePicker.setDate(date, animated: true)
    })
  }
  
  var scrollToEndOfDateTimePickerTriggerBinder: Binder<Date> {
    return Binder(self, binding: { vc, date in
      vc.expectedTimePicker.setDate(date, animated: true)
    })
  }
  
  var closeExpectedDatePickerTriggerBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.expectedDateTimeBackground.isHidden = true
      vc.expectedDatePicker.isHidden = true
      vc.expectedDatePickerOkButton.isHidden = true
      vc.expectedDatePickerClearButton.isHidden = true
    })
  }
  
  var closeExpectedTimePickerTriggerBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.expectedDateTimeBackground.isHidden = true
      vc.expectedTimePicker.isHidden = true
      vc.expectedTimePickerOkButton.isHidden = true
      vc.expectedTimePickerClearButton.isHidden = true
    })
  }
  
  // MARK: - TEXT AND DESCRIPTION BINDERS
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
  
  // MARK: - ANIMATION BINDERS
  var playAnimationViewBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.animationView.play()
    })
  }
  
  // MARK: - PHOTO
  var imageBinder: Binder<UIImage> {
    return Binder(self, binding: { (vc, image) in
      vc.resultImageView.backgroundColor = .clear
      vc.resultImageView.image = image
    })
  }
  
  // MARK: - Configure Data Source
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


