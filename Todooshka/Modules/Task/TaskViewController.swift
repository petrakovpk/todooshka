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
  public var viewModel: TaskViewModel!
  private let disposeBag = DisposeBag()

  // MARK: - UI Elements
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
    button.setTitle("Сбросить", for: .normal)
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
    button.setTitle("Сбросить", for: .normal)
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

  private let resultPhotoLabel: UILabel = {
    let label = UILabel(text: "Фото результата:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textAlignment = .left
    return label
  }()
  
  private let resultImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 8
    imageView.backgroundColor = .white
    return imageView
  }()

  private let completeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 8
    button.setTitle("Выполнено!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
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
  
  // MARK: - Complete Task Alert UI Elements
//  private let alertBackgroundView: UIView = {
//    let view = UIView()
//    view.backgroundColor = .black.withAlphaComponent(0.5)
//    view.isHidden = true
//    return view
//  }()
//
//  private let alertOkButton: UIButton = {
//    let button = UIButton(type: .system)
//    button.cornerRadius = Sizes.Buttons.AlertOkButton.height / 2
//    button.setTitle("Да, я молодец :)", for: .normal)
//    button.setTitleColor(.white, for: .normal)
//    button.backgroundColor = Style.Buttons.AlertRoseButton.Background
//    button.isHidden = true
//    return button
//  }()
//
//  private let alertAnimationView: AnimationView = {
//    let animationView = AnimationView(name: "taskDone2")
//    animationView.isHidden = true
//    animationView.contentMode = .scaleAspectFill
//    animationView.loopMode = .repeat(3.0)
//    animationView.animationSpeed = 1.0
//    animationView.isHidden = true
//    return animationView
//  }()
//
//  private let alertDatePicker: UIDatePicker = {
//    let picker = UIDatePicker()
//    picker.datePickerMode = .date
//    picker.preferredDatePickerStyle = .inline
//    picker.backgroundColor = Style.App.background
//    picker.cornerRadius = 15
//    picker.isHidden = true
//    picker.locale = Locale(identifier: "ru_RU")
//    return picker
//  }()
//
//  private let alertDatePickerOkButton: UIButton = {
//    let button = UIButton(type: .system)
//    button.cornerRadius = 12
//    button.setTitle("Выбрать", for: .normal)
//    button.setTitleColor(Style.App.text, for: .normal)
//    button.backgroundColor = Palette.SingleColors.Portage
//    button.isHidden = true
//    return button
//  }()
//
//  private let alertDatePickerCancelButton: UIButton = {
//    let button = UIButton(type: .system)
//    button.cornerRadius = 12
//    button.setTitle("Отмена", for: .normal)
//    button.setTitleColor(Style.App.text, for: .normal)
//    button.backgroundColor = Style.App.background
//    button.isHidden = true
//    return button
//  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  private func configureUI() {
    // titleLabel
    titleLabel.text = "Задача"

    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())

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
      completeButton,
      getPhotoButton
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
    
    // saveNameTextFieldButton
    saveNameTextFieldButton.centerYAnchor.constraint(equalTo: nameTextField.centerYAnchor).isActive = true
    saveNameTextFieldButton.anchor(
      right: nameTextField.rightAnchor,
      widthConstant: 24,
      heightConstant: 24
    )
    
    // expectedDateTimelabel
    expectedDateTimelabel.anchor(
      top: nameTextField.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // expectedDateButton
    expectedDateButton.anchor(
      top: expectedDateTimelabel.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16,
      widthConstant: 87,
      heightConstant: 42
    )
    
    // expectedTimeButton
    expectedTimeButton.anchor(
      top: expectedDateTimelabel.bottomAnchor,
      left: expectedDateButton.rightAnchor,
      topConstant: 8,
      leftConstant: 8,
      widthConstant: 87,
      heightConstant: 42
    )
    
    // expectedDateTimeBackground
    expectedDateTimeBackground.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor
    )
    
    // expectedDatePicker
    expectedDatePicker.anchorCenterXToSuperview()
    expectedDatePicker.anchorCenterYToSuperview()
    
    // expectedDatePickerClearButton
    expectedDatePickerClearButton.anchor(
      top: expectedDatePicker.bottomAnchor,
      left: expectedDatePicker.leftAnchor,
      topConstant: 8,
      widthConstant: expectedDatePicker.bounds.width / 2 - 4,
      heightConstant: 40
    )
    
    // expectedDatePickerOkButton
    expectedDatePickerOkButton.anchor(
      top: expectedDatePicker.bottomAnchor,
      right: expectedDatePicker.rightAnchor,
      topConstant: 8,
      widthConstant: expectedDatePicker.bounds.width / 2 - 4,
      heightConstant: 40
    )
    
    // expectedTimePicker
    expectedTimePicker.anchorCenterXToSuperview()
    expectedTimePicker.anchorCenterYToSuperview()
    
    // expectedDatePickerClearButton
    expectedTimePickerClearButton.anchor(
      top: expectedTimePicker.bottomAnchor,
      left: expectedTimePicker.leftAnchor,
      topConstant: 8,
      widthConstant: expectedTimePicker.bounds.width / 2 - 4,
      heightConstant: 40
    )
    
    // expectedDatePickerOkButton
    expectedTimePickerOkButton.anchor(
      top: expectedTimePicker.bottomAnchor,
      right: expectedTimePicker.rightAnchor,
      topConstant: 8,
      widthConstant: expectedTimePicker.bounds.width / 2 - 4,
      heightConstant: 40
    )

    // kindOfTaskLabel
    kindOfTaskLabel.anchor(
      top: expectedDateButton.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )

    // kindsOfTaskButton
    kindOfTaskSettingsButton.centerYAnchor.constraint(equalTo: kindOfTaskLabel.centerYAnchor).isActive = true
    kindOfTaskSettingsButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16
    )

    // collectionView
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

    // descriptionLabel
    descriptionLabel.anchor(
      top: collectionView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // saveDescriptionTextViewButton
    saveDescriptionTextViewButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor).isActive = true
    saveDescriptionTextViewButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16,
      widthConstant: 24,
      heightConstant: 24
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
    
    // showToTheWorldLabel
    resultPhotoLabel.anchor(
      top: dividerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    // resultPhotoButton
    resultImageView.anchorCenterXToSuperview()
    resultImageView.anchor(
      top: resultPhotoLabel.bottomAnchor,
      topConstant: 16,
      widthConstant: 100,
      heightConstant: 100
    )

    // getPhotoButton
    getPhotoButton.anchor(
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      bottomConstant: 16,
      rightConstant: 16,
      widthConstant: Sizes.Buttons.AppButton.height,
      heightConstant: Sizes.Buttons.AppButton.height
    )
    
    // completeTaskButton
    completeButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: getPhotoButton.leftAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 8,
      heightConstant: Sizes.Buttons.AppButton.height
    )
  }

//  private func configureAlert() {
//    // adding
//    view.addSubviews([
//      alertBackgroundView,
//      alertAnimationView,
//      alertDatePicker,
//      alertDatePickerOkButton,
//      alertDatePickerCancelButton
//    ])
//
//    alertAnimationView.addSubview(alertOkButton)
//
//    // alertView
//    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
//
//    // alertAnimationView
//    alertAnimationView.anchorCenterXToSuperview()
//    alertAnimationView.anchorCenterYToSuperview()
//
//    // alertDatePicker
//    alertDatePicker.anchorCenterXToSuperview()
//    alertDatePicker.anchorCenterYToSuperview()
//
//    // alertDatePickerOkButton
//    alertDatePickerOkButton.anchor(
//      top: alertDatePicker.bottomAnchor,
//      right: alertDatePicker.rightAnchor,
//      topConstant: 8,
//      widthConstant: alertDatePicker.bounds.width / 2 - 8,
//      heightConstant: 50
//    )
//
//    // alertDatePickerCancelButton
//    alertDatePickerCancelButton.anchor(
//      top: alertDatePicker.bottomAnchor,
//      left: alertDatePicker.leftAnchor,
//      topConstant: 8,
//      widthConstant: alertDatePicker.bounds.width / 2 - 8,
//      heightConstant: 50
//    )
//
//    // alertButton
//    alertOkButton.anchor(
//      top: completeButton.topAnchor,
//      left: completeButton.leftAnchor,
//      bottom: completeButton.bottomAnchor,
//      right: completeButton.rightAnchor
//    )
//  }

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
      completeButtonClickTrigger: completeButton.rx.tap.asDriver(),
      getPhotoButtonClickTrigger: getPhotoButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      // INIT
      outputs.initData.drive(initDataBinder),
      // BACK
      outputs.navigateBack.drive(),
      // TEXT
      outputs.saveNameTextFieldButtonIsHidden.drive(saveNameTextFieldButton.rx.isHidden),
      outputs.saveText.drive(),
      // EXPECTED
      outputs.expectedDateTime.drive(expectedDateTimeBinder),
      outputs.expectedDatePickerIsHidden.drive(expectedDateTimeBackground.rx.isHidden),
      outputs.expectedDatePickerIsHidden.drive(expectedDatePicker.rx.isHidden),
      outputs.expectedDatePickerIsHidden.drive(expectedDatePickerClearButton.rx.isHidden),
      outputs.expectedDatePickerIsHidden.drive(expectedDatePickerOkButton.rx.isHidden),
      outputs.saveExpectedDate.drive(),
      outputs.expectedTimePickerIsHidden.drive(expectedDateTimeBackground.rx.isHidden),
      outputs.expectedTimePickerIsHidden.drive(expectedTimePicker.rx.isHidden),
      outputs.expectedTimePickerIsHidden.drive(expectedTimePickerClearButton.rx.isHidden),
      outputs.expectedTimePickerIsHidden.drive(expectedTimePickerOkButton.rx.isHidden),
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
      // task
      outputs.taskIsNew.drive(taskIsNewBinder),
      // yandex
   //   outputs.yandexMetrika.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }

  // MARK: - Binders
  var initDataBinder: Binder<Task> {
    return Binder(self, binding: { vc, task in
      vc.nameTextField.insertText(task.text)
      vc.descriptionTextView.insertText(task.description)
      vc.expectedDatePicker.date = task.planned ?? Date()
      vc.expectedTimePicker.date = task.planned ?? Date()
    })
  }
  
  var expectedDateTimeBinder: Binder<Date> {
    return Binder(self, binding: { vc, expectedDate in
      vc.expectedDateButton.setTitle(DateFormatter.midDateFormatter.string(for: expectedDate), for: .normal)
      vc.expectedTimeButton.setTitle(DateFormatter.midTimeFormatter.string(for: expectedDate), for: .normal)
    })
  }
  
  
  
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

//  var showComleteAlertTriggerBinder: Binder<Void> {
//    return Binder(self, binding: { vc, _ in
//      let texts = ["Да, я молодец!", "Просто герой :)", "Красавчик же", "Светлое будущее приближается :)"]
//
//      // alertView
//      vc.alertBackgroundView.isHidden = false
//
//      // alertAnimationView
//      vc.alertAnimationView.isHidden = false
//      vc.alertAnimationView.animation = Animation.named("taskDone1")
//      vc.alertAnimationView.removeAllConstraints()
//      vc.alertAnimationView.anchor(top: vc.view.topAnchor, left: vc.view.leftAnchor, bottom: vc.view.bottomAnchor, right: vc.view.rightAnchor)
//      vc.alertAnimationView.play()
//
//      // alertButton
//      vc.alertOkButton.isHidden = false
//      vc.alertOkButton.setTitle(texts.randomElement(), for: .normal)
//    })
//  }

//  var showDatePickerAlertTriggerBinder: Binder<Void> {
//    return Binder(self, binding: { vc, _ in
//      // alertView
//      vc.alertBackgroundView.isHidden = false
//      vc.alertDatePicker.isHidden = false
//      vc.alertDatePickerOkButton.isHidden = false
//      vc.alertDatePickerCancelButton.isHidden = false
//      vc.dismissKeyboard()
//    })
//  }

//  var plannedButtonTextBinder: Binder<String> {
//    return Binder(self, binding: { vc, text in
//      vc.plannedDateButton.setTitle(text, for: .normal)
//    })
//  }

//  var hideAlertBinder: Binder<Void> {
//    return Binder(self, binding: { vc, _ in
//      vc.alertAnimationView.isHidden = true
//      vc.alertBackgroundView.isHidden = true
//      vc.alertDatePicker.isHidden = true
//      vc.alertDatePickerOkButton.isHidden = true
//      vc.alertDatePickerCancelButton.isHidden = true
//    })
//  }

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
