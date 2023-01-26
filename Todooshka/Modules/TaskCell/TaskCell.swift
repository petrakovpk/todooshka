//
//  TaskSwipeCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskCell: SwipeCollectionViewCell {
  static let reuseID: String = "TaskCell"
  
  public var disposeBag = DisposeBag()
  
  private var drawCompleted = false
  private var isEnabled = true
  private var oldLayer: CALayer?
  private var oldLineGradientLayer: CAGradientLayer?
  private var oldTimeLayer: CAGradientLayer?
  
  // MARK: - UI
  public let repeatButton: UIButton = {
    let attributedTitle = NSAttributedString(
      string: "В работу",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold)])
    let button = UIButton(type: .custom)
    button.setImage(Icon.refreshCircle.image, for: .normal)
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.cornerRadius = 15
    button.setTitleColor(.white, for: .normal)
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    button.setAttributedTitle(attributedTitle, for: .normal)
    return button
  }()
  
  private let taskTypeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let taskTextLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    return label
  }()
  
  private let descriptionTextLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
    label.textColor = Style.Cells.TaskList.Description
    return label
  }()
  
  private let timeView: UIView = {
    let view = UIView()
    view.cornerRadius = 8
    view.layer.masksToBounds = false
    view.backgroundColor = Style.Cells.TaskList.TimeLeftViewBackground
    return view
  }()
  
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.textColor = .white
    return label
  }()
  
  // MARK: - Lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    configureUI()
  }
  
  // MARK: - Draw
  func drawLightMode() {
    let backgroundLayer = CALayer()
    backgroundLayer.frame = bounds
    backgroundLayer.cornerRadius = 8
    backgroundLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
    backgroundLayer.shadowOpacity = 1
    backgroundLayer.shadowRadius = 5
    backgroundLayer.shadowOffset = CGSize(width: 5, height: 5)
    backgroundLayer.shadowColor = UIColor(red: 0.693, green: 0.702, blue: 0.875, alpha: 0.6).cgColor
    backgroundLayer.backgroundColor = UIColor(red: 244 / 255, green: 245 / 255, blue: 1, alpha: 1).cgColor
    
    if let oldLayer = oldLayer {
      contentView.layer.replaceSublayer(oldLayer, with: backgroundLayer)
    } else {
      contentView.layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    oldLayer = backgroundLayer
  }
  
  func drawDarkMode() {
    let gradientLayer = CAGradientLayer()
    let shapeLayer = CAShapeLayer()
    
    gradientLayer.locations = [0, 1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    gradientLayer.frame = bounds
    gradientLayer.cornerRadius = 8
    gradientLayer.colors = [
      UIColor(red: 0.074, green: 0.09, blue: 0.217, alpha: 1).cgColor,
      UIColor(red: 0.074, green: 0.09, blue: 0.217, alpha: 0).cgColor
    ]
    
    shapeLayer.frame = bounds
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
    shapeLayer.strokeColor = UIColor(hexString: "#15183C")?.cgColor
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = 1
    shapeLayer.insertSublayer(gradientLayer, at: 0)
    
    if let oldLayer = oldLayer {
      contentView.layer.replaceSublayer(oldLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    oldLayer = shapeLayer
  }
  
  // MARK: - Configure UI
  func configureUI() {
    let stackView = UIStackView(arrangedSubviews: [taskTextLabel, descriptionTextLabel])
    stackView.axis = .vertical
    
    contentView.addSubviews([
      taskTypeImageView,
      stackView,
      timeView,
      repeatButton
    ])
    
    timeView.addSubviews([
      timeLabel
    ])
    
    traitCollection.userInterfaceStyle == .dark ? drawDarkMode() : drawLightMode()
    
    contentView.cornerRadius = 11
    contentView.layer.borderWidth = 0
    contentView.layer.borderColor = UIColor(hexString: "#15183C")?.cgColor
    contentView.layer.masksToBounds = false
    contentView.tintColor = .white
    
    taskTypeImageView.anchorCenterYToSuperview()
    taskTypeImageView.anchor(
      left: contentView.leftAnchor,
      leftConstant: 8,
      widthConstant: 20,
      heightConstant: 20)
    
    stackView.anchor(
      top: contentView.topAnchor,
      left: taskTypeImageView.rightAnchor,
      bottom: contentView.bottomAnchor,
      right: timeView.leftAnchor,
      topConstant: 5,
      leftConstant: 8,
      bottomConstant: 5,
      rightConstant: 8
    )
    
    timeView.anchorCenterYToSuperview()
    timeView.anchor(
      right: contentView.rightAnchor,
      rightConstant: 8,
      widthConstant: 50,
      heightConstant: 28)
    
    timeLabel.anchorCenterYToSuperview()
    timeLabel.anchorCenterXToSuperview()
    
    repeatButton.anchorCenterYToSuperview()
    repeatButton.anchor(
      right: contentView.rightAnchor,
      rightConstant: 8,
      widthConstant: 110,
      heightConstant: 30)
  }
  
  func configure(mode: TaskCellMode, task: Task, kindOfTask: KindOfTask) {
    switch mode {
    case .redLineAndTime:
      configureLineLayout(
        percent: max((task.planned.timeIntervalSince1970 - Date().timeIntervalSince1970) / (24 * 60 * 60), 0),
        color: UIColor(hexString: "#fc3e08")!)
      timeLabel.text = task.planned.string(withFormat: "HH:mm")
      timeView.backgroundColor = task.planned < Date() ? UIColor(hexString: "FA5123") : Style.Cells.TaskList.TimeLeftViewBackground
      timeView.isHidden = false
      repeatButton.isHidden = true
    case .time:
      timeLabel.text = task.planned.string(withFormat: "HH:mm")
      timeView.backgroundColor = task.planned < Date() ? UIColor(hexString: "FA5123") : Style.Cells.TaskList.TimeLeftViewBackground
      timeView.isHidden = false
      repeatButton.isHidden = true
    case .blueLine:
      configureLineLayout(
        percent: max((task.planned.timeIntervalSince1970 - Date().timeIntervalSince1970) / (24 * 60 * 60), 0),
        color: Palette.SingleColors.BlueRibbon)
      timeView.isHidden = true
      repeatButton.isHidden = true
    case .repeatButton:
      timeView.isHidden = true
      repeatButton.isHidden = false
    case .empty:
      timeView.isHidden = true
      repeatButton.isHidden = true
    }
    
    taskTypeImageView.image = kindOfTask.icon.image.template
    taskTypeImageView.tintColor = kindOfTask.color
    
    taskTextLabel.text = task.text
    descriptionTextLabel.text = task.description
  }
  
  private func configureLineLayout(percent: Double, color: UIColor) {
    let widthConstant = percent * (contentView.frame.width.double - 22)
    let roundGradintLayer = CAGradientLayer()
    let lineGradientLayer = CAGradientLayer()
    
    roundGradintLayer.type = .radial
    roundGradintLayer.locations = [0, 1]
    roundGradintLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
    roundGradintLayer.endPoint = CGPoint(x: 1, y: 1)
    roundGradintLayer.frame = CGRect(x: -5, y: -5, width: 10, height: 10)
    roundGradintLayer.position = CGPoint(x: widthConstant.int, y: 0)
    roundGradintLayer.isHidden = widthConstant == 0
    roundGradintLayer.colors = [
      color.withAlphaComponent(1).cgColor,
      color.withAlphaComponent(0).cgColor
    ]
    
    lineGradientLayer.locations = [0, 1]
    lineGradientLayer.startPoint = CGPoint(x: 1, y: 0)
    lineGradientLayer.endPoint = CGPoint(x: 0, y: 0)
    lineGradientLayer.frame = CGRect(x: 11, y: contentView.height.double, width: widthConstant, height: 1.0)
    lineGradientLayer.insertSublayer(roundGradintLayer, at: 0)
    lineGradientLayer.isHidden = widthConstant == 0
    lineGradientLayer.zPosition = 10
    lineGradientLayer.colors = [
      color.withAlphaComponent(1).cgColor,
      color.withAlphaComponent(0).cgColor
    ]
    
    if let oldLineGradientLayer = oldLineGradientLayer {
      contentView.layer.replaceSublayer(oldLineGradientLayer, with: lineGradientLayer)
    } else {
      contentView.layer.insertSublayer(lineGradientLayer, at: 0)
    }
    
    oldLineGradientLayer = lineGradientLayer
  }
}
