//
//  ExtPhotoPickerController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.05.2023.
//

import AnyImageKit
import RxSwift
import RxCocoa

class CameraPickerController: ImageCaptureController {
  public var viewModel: CameraPickerViewModel!
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
  }
  
  init(options: CaptureOptionsInfo) {
    super.init()
    super.update(options: options)
    super.captureDelegate = self
  }
  
  required init() {
    fatalError("init() has not been implemented")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bindViewModel() {
    let input = CameraPickerViewModel.Input()
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.savePhoto.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
}

extension CameraPickerController: ImageCaptureControllerDelegate {
  func imageCapture(_ capture: AnyImageKit.ImageCaptureController, didFinishCapturing result: AnyImageKit.CaptureResult) {
    viewModel.didFinishCapturing.accept(result)
    capture.dismiss(animated: true, completion: nil)
  }
}

