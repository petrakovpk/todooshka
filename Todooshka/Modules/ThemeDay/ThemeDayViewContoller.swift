//
//  ThemeDayViewContoller.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import RxCocoa
import RxSwift

class ThemeDayViewContoller: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: ThemeDayViewModel!
  
  // MARK: - UI Elements
  private let addImageButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "plus")?.template, for: .normal)
    button.tintColor = .black
    button.cornerRadius = 75.0 / 2
    button.borderWidth = 1.0
    button.borderColor = .black
    return button
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .systemRed.withAlphaComponent(0.2)
    imageView.isHidden = true
    return imageView
  }()
  
  private let addTaskButton: UIButton = {
    let button = UIButton(type: .system)
    button.borderWidth = 1.0
    button.borderColor = .black
    button.cornerRadius = 3.0
    button.setTitle("Добавить задачу", for: .normal)
    button.setTitleColor(.black, for: .normal)
    return button
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 5.0
    textView.borderWidth = 1.0
    textView.borderColor = .black
    textView.backgroundColor = .clear
    return textView
  }()
  
  private let tasksLabel: UILabel = {
    let label = UILabel()
    label.text = "Задачи дня:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  func configureUI() {
    backButton.isHidden = false
    hideKeyboardWhenTappedAround()
    
    view.addSubviews([
      addImageButton,
      imageView,
      addTaskButton,
      descriptionTextView,
      tasksLabel
    ])
    
    // addImageButton
    addImageButton.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 75,
      heightConstant: 75
    )
    
    // imageView
    imageView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 75,
      heightConstant: 75
    )
    
    // descriptionTextView
    descriptionTextView.anchor(
      top: headerView.bottomAnchor,
      left: addImageButton.rightAnchor,
      bottom: addImageButton.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // tasksLabel
    tasksLabel.anchor(
      top: addImageButton.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    addTaskButton.centerYAnchor.constraint(equalTo: tasksLabel.centerYAnchor).isActive = true
    addTaskButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16,
      widthConstant: 160.0,
      heightConstant: 25.0
    )
  }
  
  func bindViewModel() {
    let input = ThemeDayViewModel.Input(
      addThemeTaskIsRequired: addTaskButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.addThemeTask.drive(),
      outputs.navigateBack.drive(),
      outputs.openViewControllerMode.drive(openViewControllerModeBinder)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  var openViewControllerModeBinder: Binder<OpenViewControllerMode> {
    return Binder(self, binding: { vc, mode in
      switch mode {
      case .edit:
        vc.addImageButton.isHidden = false
        vc.addTaskButton.isHidden = false
        vc.descriptionTextView.isEditable = true
        vc.imageView.isHidden = true
      case .view:
        vc.addImageButton.isHidden = true
        vc.addTaskButton.isHidden = true
        vc.descriptionTextView.isEditable = false
        vc.imageView.isHidden = false
      }
    })
  }
}
