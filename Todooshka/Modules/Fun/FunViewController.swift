//
//  FeedViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 18.11.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture

class FunViewController: TDViewController {
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: FunViewModel!
  
  // MARK: - UI Elements
  private let authorImageView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = .black.withAlphaComponent(0.2)
    view.cornerRadius = 5
    return view
  }()
  
  private let authorNameLabel: UILabel = {
    let label = UILabel()
    label.text = "Eric Coolguard"
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  
  private let taskTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 2
    label.text = "Помыть машину"
    return label
  }()
  
  private let contentImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5
    imageView.backgroundColor = .black.withAlphaComponent(0.2)
    return imageView
  }()
  
  private let badButton: UIButton = {
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 5
    button.backgroundColor = Palette.SingleColors.BrinkPink
    button.setTitle("Не очень", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return button
  }()
  
  private let goodButton: UIButton = {
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 5
    button.backgroundColor =  Palette.SingleColors.Shamrock
    button.setTitle("Одобряем", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return button
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // header
    headerView.layer.zPosition = 2
    titleLabel.text = "It's fun"
    
    // adding
    view.addSubviews([
      authorImageView,
      authorNameLabel,
      taskTextLabel,
      contentImageView,
      badButton,
      goodButton
    ])
    
    // authorImageView
    authorImageView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 50,
      heightConstant: 50
    )
    
    // authorNameLabel
    authorNameLabel.anchor(
      top: headerView.bottomAnchor,
      left: authorImageView.rightAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // taskTextLabel
    taskTextLabel.anchor(
      top: authorNameLabel.bottomAnchor,
      left: authorImageView.rightAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // contentImageView
    contentImageView.anchor(
      top: authorImageView.bottomAnchor,
      left: view.leftAnchor,
      bottom: badButton.topAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
    
    // badButton
    badButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 2 - 16 - 8,
      heightConstant: 50
    )
    
    // coolButton
    goodButton.anchor(
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      bottomConstant: 16,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 2 - 16 - 8,
      heightConstant: 50
    )
    
   
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = FunViewModel.Input(
      authorImageClickTrigger: authorImageView.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      authorNameClickTrigger: authorNameLabel.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      taskTextClickTrigger: taskTextLabel.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      badButtonClickTrigger: badButton.rx.tap.asDriver(),
      goodButtonClickTrigger: goodButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

//    [
//    
//    ]
//      .forEach { $0.disposed(by: disposeBag) }
  }
  
}

