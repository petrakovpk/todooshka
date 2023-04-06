//
//  ResultPreviewViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 02.03.2023.
//

import RxCocoa
import RxSwift
import UIKit

class ResultPreviewViewController: TDViewController {
  public var viewModel: ResultPreviewViewModel!
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Elements
  private let authorImageView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = .black.withAlphaComponent(0.2)
    view.cornerRadius = 5
    return view
  }()
  
  private let authorNameLabel: UILabel = {
    let label = UILabel()
    label.text = "Eric Coolguard"
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  
  private let textLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 2
    label.text = ""
    return label
  }()
  
  private let resultImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5
    imageView.backgroundColor = .black.withAlphaComponent(0.2)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let removePhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 5
    button.backgroundColor = Palette.SingleColors.BrinkPink
    button.setTitle("Удалить фото", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return button
  }()
  
  private let addPhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 5
    button.backgroundColor =  Palette.SingleColors.Shamrock
    button.setTitle("Переснять", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  func configureUI() {
    backButton.isHidden = false
    titleLabel.text = "Result preview"
    
    view.addSubviews([
      authorImageView,
      authorNameLabel,
      textLabel,
      resultImageView,
      removePhotoButton,
      addPhotoButton
    ])
    
    authorImageView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 50,
      heightConstant: 50
    )
    
    authorNameLabel.anchor(
      top: headerView.bottomAnchor,
      left: authorImageView.rightAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )
    
    textLabel.anchor(
      top: authorNameLabel.bottomAnchor,
      left: authorImageView.rightAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    resultImageView.anchor(
      top: authorImageView.bottomAnchor,
      left: view.leftAnchor,
      bottom: removePhotoButton.topAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
    
    removePhotoButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 2 - 16 - 8,
      heightConstant: 50
    )
    
    addPhotoButton.anchor(
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      bottomConstant: 16,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 2 - 16 - 8,
      heightConstant: 50
    )
  }
  
  func bindViewModel() {
    let input = ResultPreviewViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.navigateBack.drive(),
      outputs.text.drive(textLabel.rx.text),
      outputs.image.drive(resultImageView.rx.image)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
}
