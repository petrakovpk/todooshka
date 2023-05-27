//
//  PublicationViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.05.2023.
//

import RxCocoa
import RxSwift
import UIKit

class PublicationViewController: TDViewController {
  public var viewModel: PublicationViewModel!
  
  private let disposeBag = DisposeBag()
  
  private let publicationTextView: PlaceholderTextView = {
    let textView = PlaceholderTextView()
    textView.backgroundColor = .lightGray.withAlphaComponent(0.2)
    textView.cornerRadius = 15
    textView.isEditable = false
    textView.textAlignment = .center
    return textView
  }()

  private let publicationImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .lightGray.withAlphaComponent(0.2)
    imageView.cornerRadius = 8
    return imageView
  }()

  private let publishButton: UIButton = {
    let button = UIButton(type: .system)
    let spacing = 10.0
    button.setTitle("Опубликовать", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.Rose
    button.cornerRadius = 8
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    publicationTextView.centerVerticalText()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    publicationTextView.centerVerticalText()
  }

  func configureUI() {
    backButton.isHidden = false
    moreButton.isHidden = false
    
    hideKeyboardWhenTappedAround()
    
    view.addSubviews([
      publicationTextView,
     // kindImageView,
      publishButton,
      publicationImageView
    ])
    
//    kindImageView.anchor(
//      top: headerView.bottomAnchor,
//      right: view.rightAnchor,
//      topConstant: 16,
//      rightConstant: 16,
//      widthConstant: 50,
//      heightConstant: 50
//    )
    
    publicationTextView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )

    publishButton.anchor(
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
      bottom: publishButton.topAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 8,
      rightConstant: 16
    )
  }
  
  func bindViewModel() {
    let input = PublicationViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      moreButtonClickTrigger: moreButton.rx.tap.asDriver(),
      // bottom buttons
      publishButtonClickTrigger: publishButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // header
      outputs.navigateBack.drive(),
      outputs.navigateToPublicationSettings.drive(),
      outputs.titleHeader.drive(titleLabel.rx.text),
      // publicKind
      //outputs.publicKindUIImage.drive(kindImageView.rx.image),
      // publication
      outputs.publicationText.drive(publicationTextView.rx.text),
      outputs.publicationUIImage.drive(publicationImageView.rx.image),
      // bottom button
      outputs.publishButtonIsEnabled.drive(publishButtonIsEnabledBinder),
      outputs.publish.drive(),
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  var publishButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      if isEnabled {
        vc.publishButton.backgroundColor = Palette.SingleColors.Rose
        vc.publishButton.isEnabled = true
      } else {
        vc.publishButton.backgroundColor = Palette.SingleColors.Rose.withAlphaComponent(0.2)
        vc.publishButton.isEnabled = false
      }
    })
  }

}
