//
//  SearchQuestsViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 24.05.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchQuestsViewController: UIViewController {
  private let disposeBag = DisposeBag()

  public var viewModel: SearchQuestsViewModel!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    view.backgroundColor = .random.withAlphaComponent(0.3)
  }
  

  // MARK: - Bind ViewModel
  func bindViewModel() {
//    let input = SearchQuestsViewModel.Input(
//      // header
//      backButtonClickTrigger: backButton.rx.tap.asDriver()
//    )
//
//    let outputs = viewModel.transform(input: input)
//    
//    [
//      outputs.navigateBack.drive()
//    ]
//      .forEach { $0.disposed(by: disposeBag) }
  }
}

