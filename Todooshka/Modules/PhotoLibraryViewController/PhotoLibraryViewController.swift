//
//  PhotoLibraryViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.05.2023.
//

import AnyImageKit
import RxSwift
import RxCocoa

class PhotoLibraryViewController: ImagePickerController {
  public var viewModel: PhotoLibraryViewModel!
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
  }
  
  init(options: PickerOptionsInfo) {
    super.init()
    super.update(options: options)
    super.pickerDelegate = self
  }
  
  required init() {
    fatalError("init() has not been implemented")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bindViewModel() {
    let input = PhotoLibraryViewModel.Input()
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.savePublicationImage.drive(),
      outputs.saveQuestImage.drive(),
      outputs.saveExtUserDataImage.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
}

extension PhotoLibraryViewController: ImagePickerControllerDelegate {
  func imagePickerDidCancel(_ picker: AnyImageKit.ImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePicker(_ picker: AnyImageKit.ImagePickerController, didFinishPicking result: AnyImageKit.PickerResult) {
    viewModel.didFinishPickingResult.accept(result)
    picker.dismiss(animated: true, completion: nil)
  }
  
}
