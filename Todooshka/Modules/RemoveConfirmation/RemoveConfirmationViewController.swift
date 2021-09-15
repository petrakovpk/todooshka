//
//  RemoveConfirmationViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 12.09.2021.
//

import UIKit

class RemoveConfirmationViewController: UIViewController {
  
  //MARK: - Properties
  var viewModel: RemoveConfirmationViewModel!
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  //MARK: - ConfigureUI
  func configureUI() {
    view.backgroundColor = .black
  }
  
  //MARK: - Bind
  func bindTo(with viewModel: RemoveConfirmationViewModel) {
    self.viewModel = viewModel
  }
}
