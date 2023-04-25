//
//  KindOfTaskColorCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 15.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

class KindColorCell: UICollectionViewCell {
  static var reuseID: String = "KindColorCell"

  private let radius: CGFloat = 20
  private let iconImageView = UIImageView()
  private let icon = Icon.tick.image.template

  private let shapeLayer = CAShapeLayer()
  private var oldShapeLayer: CAShapeLayer?

  // MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    configureUI()
  }

  func configureUI() {
    contentView.addSubview(iconImageView)

    contentView.cornerRadius = contentView.bounds.height / 2

    iconImageView.image = icon
    iconImageView.tintColor = Style.App.background
    iconImageView.anchorCenterXToSuperview()
    iconImageView.anchorCenterYToSuperview()

    shapeLayer.lineWidth = 4.0
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = Style.App.background!.cgColor
    shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
    shapeLayer.position = CGPoint(x: contentView.center.x - radius, y: contentView.center.y - radius)

    if let oldShapeLayer = oldShapeLayer {
      contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }

    oldShapeLayer = shapeLayer
  }

  func configure(with item: KindColorItem) {
    iconImageView.isHidden = !item.isSelected
    shapeLayer.isHidden = !item.isSelected
    UIView.performWithoutAnimation {
      contentView.backgroundColor = item.color
    }
  }
}
