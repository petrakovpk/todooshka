//
//  PublicationEditViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 19.05.2023.
//

import RxCocoa
import RxSwift
import UIKit

class PublicationEditViewController: TDViewController {
  public var viewModel: PublicationEditViewModel!
  
  private let disposeBag = DisposeBag()
  
  private let publicationTextView: PlaceholderTextView = {
    let textView = PlaceholderTextView()
    textView.backgroundColor = .lightGray.withAlphaComponent(0.2)
    textView.cornerRadius = 8
    return textView
  }()
  
  private let kindImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 8
    imageView.backgroundColor = .lightGray.withAlphaComponent(0.2)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let publicationImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .lightGray.withAlphaComponent(0.2)
    imageView.cornerRadius = 8
    return imageView
  }()

  private let saveButton: UIButton = {
    let button = UIButton(type: .system)
    let spacing = 10.0
    button.setTitle("Сохранить", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.cornerRadius = 8
    return button
  }()

  private let photoLibraryButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.gallery.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()
  
  private let cameraButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.camera.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()
  
  private let clearButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.trash.image.template, for: .normal)
    button.backgroundColor = Style.App.background
    button.tintColor = Palette.SingleColors.Rose
    return button
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
      kindImageView,
      publicationTextView,
      photoLibraryButton,
      cameraButton,
      saveButton,
      publicationImageView,
      clearButton
    ])
    
    kindImageView.anchor(
      top: headerView.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: 50,
      heightConstant: 50
    )
    
    publicationTextView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: kindImageView.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 8,
      heightConstant: 50
    )

    saveButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )
    
    publicationImageView.anchor(
      top: publicationTextView.bottomAnchor,
      left: view.leftAnchor,
      bottom: saveButton.topAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 8,
      rightConstant: 16
    )
    
    photoLibraryButton.cornerRadius = 20
    photoLibraryButton.anchor(
      left: publicationImageView.leftAnchor,
      bottom: publicationImageView.bottomAnchor,
      leftConstant: (UIScreen.main.bounds.width - 16 * 2 - 16 - 40 * 2) / 2,
      bottomConstant: 16,
      widthConstant: 40,
      heightConstant: 40
    )
    
    cameraButton.cornerRadius = 20
    cameraButton.anchor(
      bottom: publicationImageView.bottomAnchor,
      right: publicationImageView.rightAnchor,
      bottomConstant: 16,
      rightConstant: (UIScreen.main.bounds.width - 16 * 2 - 16 - 40 * 2) / 2,
      widthConstant: 40,
      heightConstant: 40
    )
    
    clearButton.cornerRadius = 20
    clearButton.anchor(
      top: publicationImageView.topAnchor,
      right: publicationImageView.rightAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: 40,
      heightConstant: 40
    )
  }
  
  func bindViewModel() {
    
    let input = PublicationEditViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // text
      publicationTextView: publicationTextView.rx.text.asDriver(),
      // publicationImageView
      publicKindClickTrigger: kindImageView.rx.tapGesture().when(.recognized).mapToVoid().asDriver(onErrorJustReturn: ()),
      // bottom buttons
      photoLibraryButtonClickTrigger: photoLibraryButton.rx.tap.asDriver(),
      cameraButtonClickTrigger: cameraButton.rx.tap.asDriver(),
      clearButtonClickTrigger: clearButton.rx.tap.asDriver(),
      saveButtonClickTrigger: saveButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // header
      outputs.navigateBack.drive(),
      outputs.openPublicKind.drive(),
      outputs.publicKindUIImage.drive(kindImageView.rx.image),
      // publication
      outputs.publicationText.drive(publicationTextBinder),
      outputs.publicationUIImage.drive(publicationImageView.rx.image),
      outputs.publicationClearImage.drive(),
      outputs.publicationOpenCamera.drive(),
      outputs.publicationOpenPhotoLibrary.drive(),
      outputs.publicationClearImageButtonIsHidden.drive(clearButton.rx.isHidden),
      outputs.publicationAddImageButtonsIsHidden.drive(cameraButton.rx.isHidden),
      outputs.publicationAddImageButtonsIsHidden.drive(photoLibraryButton.rx.isHidden),
      // save
      outputs.publicationSaveToCoreData.drive(),
      outputs.publicationImageSaveToCoreData.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  var publicationTextBinder: Binder<String?> {
    return Binder(self, binding: { vc, text in
      if let text = text {
        vc.publicationTextView.text = text
        vc.publicationTextView.placeholder = nil
      } else {
        vc.publicationTextView.text = nil
        vc.publicationTextView.placeholder = "Что сделали?"
      }
    })
  }

}

