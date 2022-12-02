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
  private let taskView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemRed.withAlphaComponent(0.2)
    view.cornerRadius = 12
    return view
  }()
  
  private var contentView = TDContentView(type: .image)
  
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
    
    view.addSubviews([
      taskView,
      contentView
    ])
    
    // taskView
    taskView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 75
    )
    
    // userContentImageView
    contentView.anchor(
      top: taskView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16 + 15,
      rightConstant: 16
    )
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = FunViewModel.Input(
      swipeTrigger: contentView.rx.swipeGesture([.left, .right]).asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.nextContent.drive(nextContentBinder)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  var nextContentBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      print("1234 next")
    })
  }

}

