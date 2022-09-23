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
  
  // MARK: - Public
  static let reuseID: String = "TaskCell"
  
  var disposeBag = DisposeBag()

  // MARK: - Public
  // UI
  public let repeatButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "refresh-circle")?.original, for: .normal)
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.cornerRadius = 15
    button.setTitleColor(.white, for: .normal)
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4);
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0);
    
    let attributedTitle = NSAttributedString(string: "В работу", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11, weight: .semibold)])
    button.setAttributedTitle(attributedTitle , for: .normal)
    
    return button
  }()
  
  // MARK: - Private
  // Properties
  private var isEnabled: Bool = true
  private var oldLayer: CALayer?
  private var oldLineGradientLayer: CAGradientLayer?
  private var oldTimeLayer: CAGradientLayer?
  
  // UI
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
    label.textColor = Theme.TaskList.Cell.descriptionText
    return label
  }()
  
  private let taskTimeLeftView: UIView = {
    let view = UIView()
    view.cornerRadius = 15
    view.layer.masksToBounds = false
    view.backgroundColor = Theme.TaskList.Cell.timeLeftViewBackground
    return view
  }()
  
  private let taskTimeLeftImageView = UIImageView(image: UIImage(named: "timer"))
  
  private let taskTimeLeftLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
    label.text = ""
    label.textColor = .white
    return label
  }()
  
  private let taskTimeLeftLineView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemBlue
    return view
  }()
  
  // MARK: - Lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }

  // MARK: - Draw
  override func draw(_ rect: CGRect) {
    configureUI()
  }
  
  func drawLightMode() {
    
    let backgroundLayer = CALayer()
    backgroundLayer.frame = bounds
    backgroundLayer.cornerRadius = 11
    backgroundLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
    backgroundLayer.shadowOpacity = 1
    backgroundLayer.shadowRadius = 5
    backgroundLayer.shadowOffset = CGSize(width: 5, height: 5)
    backgroundLayer.shadowColor = UIColor(red: 0.693, green: 0.702, blue: 0.875, alpha: 0.6).cgColor
    backgroundLayer.backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 1, alpha: 1).cgColor
    
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
    
    // gradientLayer
    gradientLayer.locations = [0,1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    gradientLayer.frame = bounds
    gradientLayer.cornerRadius = 11
    gradientLayer.colors = [
      UIColor(red: 0.074, green: 0.09, blue: 0.217, alpha: 1).cgColor,
      UIColor(red: 0.074, green: 0.09, blue: 0.217, alpha: 0).cgColor
    ]
    
    // shapeLayer
    shapeLayer.frame = bounds
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
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
  
  func configureTimerRound() {
    let path = UIBezierPath()
    let animation = CAKeyframeAnimation(keyPath: "position")
    let roundGradintLayer = CAGradientLayer()
    let size = CGSize(width: contentView.bounds.width, height: contentView.bounds.height)
    let cornerRadius = CGFloat(11)
    
    // path
    path.move(to: CGPoint(x: size.width / 2, y: 0))
    path.addLine(to: CGPoint(x: size.width - cornerRadius, y: 0))
    path.addArc(withCenter: CGPoint(x: size.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: -.pi / 2 , endAngle: 0, clockwise: true)
    path.addLine(to: CGPoint(x: size.width, y: size.height - cornerRadius))
    path.addArc(withCenter: CGPoint(x: size.width - cornerRadius, y: size.height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
    path.addLine(to: CGPoint(x: cornerRadius, y: size.height))
    path.addArc(withCenter: CGPoint(x: cornerRadius, y: size.height - cornerRadius), radius: cornerRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
    path.addLine(to: CGPoint(x: 0, y: cornerRadius))
    path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: -.pi / 2, clockwise: true)
    path.addLine(to: CGPoint(x: size.width / 2, y: 0))
    
    // animation
    animation.path = path.cgPath
    animation.duration = 60
    animation.repeatCount = .infinity
    
    // roundGradintLayer
    roundGradintLayer.locations = [0,1]
    roundGradintLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
    roundGradintLayer.endPoint = CGPoint(x: 1, y: 1)
    roundGradintLayer.frame = CGRect(x: -5, y: -5, width: 10, height: 10)
    roundGradintLayer.position = CGPoint(x: size.width / 2, y: 0)
    roundGradintLayer.add(animation, forKey: "animateBall")
    roundGradintLayer.type = .radial
    roundGradintLayer.colors = [
      UIColor(hexString: "#fc3e08")!.withAlphaComponent(1).cgColor,
      UIColor(hexString: "#fc3e08")!.withAlphaComponent(0).cgColor,
    ]
    
    if let oldTimeLayer = oldTimeLayer {
      contentView.layer.replaceSublayer(oldTimeLayer, with: roundGradintLayer)
    } else {
      contentView.layer.insertSublayer(roundGradintLayer, at: 0)
    }
    
    oldTimeLayer = roundGradintLayer
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    // contentView
    contentView.addSubview(repeatButton)
    contentView.addSubview(taskTextLabel)
    contentView.addSubview(descriptionTextLabel)
    contentView.addSubview(taskTypeImageView)
    contentView.addSubview(taskTimeLeftView)
    taskTimeLeftView.addSubview(taskTimeLeftImageView)
    taskTimeLeftView.addSubview(taskTimeLeftLabel)
    
    traitCollection.userInterfaceStyle == .dark ? drawDarkMode() : drawLightMode()
    
    // contentView
    contentView.cornerRadius = 11
    contentView.layer.borderWidth = 0
    contentView.layer.borderColor = UIColor(hexString: "#15183C")?.cgColor
    contentView.layer.masksToBounds = false
    contentView.tintColor = .white
    
    // taskTypeImageView
    taskTypeImageView.anchorCenterYToSuperview()
    taskTypeImageView.anchor(left: contentView.leftAnchor, leftConstant: 8, widthConstant: 20, heightConstant: 20)
    
    // taskTimeLeftView
    taskTimeLeftView.anchorCenterYToSuperview()
    taskTimeLeftView.anchor(right: contentView.rightAnchor, rightConstant: 8, widthConstant: 110, heightConstant: 30)
    
    // taskTimeLeftImageView
    taskTimeLeftImageView.anchorCenterYToSuperview()
    taskTimeLeftImageView.anchor(left: taskTimeLeftView.leftAnchor, leftConstant: 10, widthConstant: 13, heightConstant: 13)
    
    // taskTimeLeftLabel
    taskTimeLeftLabel.anchorCenterYToSuperview()
    taskTimeLeftLabel.anchor(left: taskTimeLeftImageView.rightAnchor, right: taskTimeLeftView.rightAnchor, leftConstant: 3, rightConstant: 10, widthConstant: 40)
    
    // repeatButton
    repeatButton.anchorCenterYToSuperview()
    repeatButton.anchor(right: contentView.rightAnchor, rightConstant: 8, widthConstant: 110, heightConstant: 30)
    
    // taskTextLabel
    taskTextLabel.removeAllConstraints()
    
    // descriptionTextLabel
    descriptionTextLabel.removeAllConstraints()
    
    if let description = descriptionTextLabel.text, description != "" {
      taskTextLabel.anchor(top: contentView.topAnchor, left: taskTypeImageView.rightAnchor, right: taskTimeLeftView.leftAnchor, topConstant: 12, leftConstant: 8, rightConstant: 8)
      descriptionTextLabel.anchor(top: taskTextLabel.bottomAnchor, left: taskTypeImageView.rightAnchor, right: taskTimeLeftView.leftAnchor, topConstant: 3, leftConstant: 8, rightConstant: 8)
    } else {
      taskTextLabel.anchorCenterYToSuperview()
      taskTextLabel.anchor(left: taskTypeImageView.rightAnchor, right: taskTimeLeftView.leftAnchor, leftConstant: 8, rightConstant: 8)
    }
  }
  
  func configure(with mode: TaskCellMode) {
    switch mode {
    case .WithTimer:
      taskTimeLeftView.isHidden = false
      repeatButton.isHidden = true
    case .WithRepeatButton:
      taskTimeLeftView.isHidden = true
      repeatButton.isHidden = false
    case .WithFeather:
      taskTimeLeftView.isHidden = true
      repeatButton.isHidden = true
    }
  }
  
  func configure(with task: Task) {
    taskTextLabel.text = task.text
    descriptionTextLabel.text = task.description
    taskTimeLeftLabel.text = task.timeLeftText
    configureLineLayout(with: task.timeLeftPercent)
  }
  
  func configure(with kindOfTask: KindOfTask) {
    taskTypeImageView.image = kindOfTask.icon.image
    taskTypeImageView.tintColor = kindOfTask.color
  }
  
  // MARK: - Configure UI
  private func configureLineLayout(with percent: Double) {
    
    let widthConstant = percent * (contentView.frame.width.double - 22)
    let roundGradintLayer = CAGradientLayer()
    let lineGradientLayer = CAGradientLayer()
    
    // roundGradintLayer
    roundGradintLayer.type = .radial
    roundGradintLayer.locations = [0,1]
    roundGradintLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
    roundGradintLayer.endPoint = CGPoint(x: 1, y: 1)
    roundGradintLayer.frame = CGRect(x: -5, y: -5, width: 10, height: 10)
    roundGradintLayer.position = CGPoint(x: widthConstant.int, y: 0)
    roundGradintLayer.isHidden = widthConstant == 0
    roundGradintLayer.colors = [
      UIColor(hexString: "#fc3e08")!.withAlphaComponent(1).cgColor,
      UIColor(hexString: "#fc3e08")!.withAlphaComponent(0).cgColor,
    ]
    
    // lineGradientLayer
    lineGradientLayer.locations = [0,1]
    lineGradientLayer.startPoint = CGPoint(x: 1, y: 0)
    lineGradientLayer.endPoint = CGPoint(x: 0, y: 0)
    lineGradientLayer.frame = CGRect(x: 11, y: contentView.height.double, width: widthConstant, height: 1.0)
    lineGradientLayer.insertSublayer(roundGradintLayer, at: 0)
    lineGradientLayer.isHidden = widthConstant == 0
    lineGradientLayer.zPosition = 10
    lineGradientLayer.colors = [
      UIColor(hexString: "#fc3e08")!.withAlphaComponent(1).cgColor,
      UIColor(hexString: "#fc3e08")!.withAlphaComponent(0).cgColor,
    ]
    
    if let oldLineGradientLayer = oldLineGradientLayer {
      contentView.layer.replaceSublayer(oldLineGradientLayer, with: lineGradientLayer)
    } else {
      contentView.layer.insertSublayer(lineGradientLayer, at: 0)
    }
    
    oldLineGradientLayer = lineGradientLayer
  }
}
