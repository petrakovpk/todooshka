//
//  UserListViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import RxSwift
import RxCocoa
import RxDataSources
import UIKit

class UserListViewController: TDViewController {
  public var viewModel: UserListViewModel!

  private let disposeBag = DisposeBag()


  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    //configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    
  }

  // MARK: - Bind To
  func bindViewModel() {
    
    let input = UserListViewModel.Input(
      // header button
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)
    
    [
      // header
      outputs.navigateBack.drive(),
    ]
      .forEach { $0?.disposed(by: disposeBag) }
  }
}
