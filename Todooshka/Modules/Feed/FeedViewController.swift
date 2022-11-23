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

class FeedViewController: TDViewController {
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: FeedViewModel!
  
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
    titleLabel.text = "Новости"
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = FeedViewModel.Input(
      
    )

    let outputs = viewModel.transform(input: input)

//    [
//
//    ]
//      .forEach { $0.disposed(by: disposeBag) }
  }

}

