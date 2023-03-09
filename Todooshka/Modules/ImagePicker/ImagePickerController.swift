//
//  TaskImagePickerController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 30.01.2023.
//

import UIKit
import RxSwift
import RxCocoa

class ImagePickerController: UIImagePickerController {
  public var viewModel: ImagePickerViewModel!

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  func configureUI() {

  }
  
  func bindViewModel() {
    let input = ImagePickerViewModel.Input()
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.saveImage.drive(),
      outputs.updateTask.drive(),
      outputs.dismiss.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }

}

extension ImagePickerController: UIImagePickerControllerDelegate {
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    viewModel.cancelButtonClickTrigger.accept(())
  }

  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    viewModel.imageButtonClickTrigger.accept(info)
  }
  
}

extension ImagePickerController: UINavigationControllerDelegate {
  
}
