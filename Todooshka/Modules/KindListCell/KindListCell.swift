//
//  KindOfTaskListCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.08.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class KindListCell: SwipeCollectionViewCell {
  static var reuseID: String = "KindListCell"

  var disposeBag = DisposeBag()

  let repeatButton: UIButton = {
    let attributedTitle = NSAttributedString(
      string: "Актививировать",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold)])
    let button = UIButton(type: .system)
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.cornerRadius = 25 / 2
    button.setImage(Icon.refreshCircle.image, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.isHidden = true
    return button
  }()

  private let leftImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private let rightImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.isHidden = false
    return imageView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    return label
  }()

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    configureUI()
  }

  // MARK: - Lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }

  // MARK: - Configure
  func configureUI() {
    contentView.addSubviews([
      leftImageView,
      nameLabel,
      rightImageView,
      repeatButton
    ])

    contentView.cornerRadius = height / 2
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = Style.Cells.Kind.Border?.cgColor
    contentView.backgroundColor = Style.Cells.Kind.UnselectedBackground
    contentView.layer.masksToBounds = false

    leftImageView.anchorCenterYToSuperview()
    leftImageView.anchor(
      left: contentView.leftAnchor,
      leftConstant: 8,
      widthConstant: 40)

    repeatButton.anchorCenterYToSuperview()
    repeatButton.anchor(
      right: contentView.rightAnchor,
      rightConstant: 4,
      widthConstant: 120,
      heightConstant: 25)

    rightImageView.anchorCenterYToSuperview()
    rightImageView.anchor(
      right: contentView.rightAnchor,
      rightConstant: 8,
      widthConstant: 40)

    nameLabel.anchorCenterYToSuperview()
    nameLabel.anchor(
      left: leftImageView.rightAnchor,
      right: repeatButton.leftAnchor,
      leftConstant: 8)
  }

  func configure(with item: KindListItem) {
    let kind = item.kind
    let mode = item.cellMode
        
    leftImageView.image = kind.icon?.image.template
    leftImageView.tintColor = kind.color
    nameLabel.text = kind.text

    switch mode {
    case .empty:
      repeatButton.isHidden = true
      rightImageView.isHidden = true

    case .repeatButton:
      repeatButton.isHidden = false
      rightImageView.isHidden = true

    case .withRightImage:
      repeatButton.isHidden = true
      rightImageView.isHidden = false
      rightImageView.image = kind.icon?.image
      rightImageView.tintColor = Style.App.text
      
    default:
      return
    }
  }
}
