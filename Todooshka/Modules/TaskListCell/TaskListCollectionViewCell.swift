//
//  TaskListCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskListCollectionViewCell: SwipeCollectionViewCell {
    
    //MARK: - Properties
    static var reuseID: String = "TaskListCollectionViewCell"
    var viewModel: TaskListCollectionViewCellModel!
    var disposeBag = DisposeBag()
    
    var oldShapeLayer: CAShapeLayer?
    var oldLineGradientLayer: CAGradientLayer?
    
    override func draw(_ rect: CGRect) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
        
        shapeLayer.strokeColor = UIColor(hexString: "#15183C")?.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
                    UIColor(red: 0.074, green: 0.09, blue: 0.217, alpha: 1).cgColor,
                    UIColor(red: 0.074, green: 0.09, blue: 0.217, alpha: 0).cgColor
                ]
        
        gradientLayer.locations = [0,1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 11
        
        shapeLayer.insertSublayer(gradientLayer, at: 0)
        
        if let oldShapeLayer = oldShapeLayer {
            contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            contentView.layer.insertSublayer(shapeLayer, at: 0)
        }
        
        oldShapeLayer = shapeLayer
    }
    
    private func configurelineLayout(widthConstant: Double) {
        
        if widthConstant == 0 { return }
        
        let roundGradintLayer = CAGradientLayer()
        roundGradintLayer.type = .radial
        roundGradintLayer.colors = [
            UIColor(hexString: "#fc3e08")!.withAlphaComponent(1).cgColor,
            UIColor(hexString: "#fc3e08")!.withAlphaComponent(0).cgColor,
        ]

        roundGradintLayer.locations = [0,1]
        roundGradintLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        roundGradintLayer.endPoint = CGPoint(x: 1, y: 1)
        roundGradintLayer.frame = CGRect(x: -5, y: -5, width: 10, height: 10)
        roundGradintLayer.position = CGPoint(x: widthConstant.int, y: 0)
        
        let lineGradientLayer = CAGradientLayer()
        lineGradientLayer.colors = [
            UIColor(hexString: "#fc3e08")!.withAlphaComponent(1).cgColor,
            UIColor(hexString: "#fc3e08")!.withAlphaComponent(0).cgColor,
        ]

        lineGradientLayer.locations = [0,1]
        lineGradientLayer.startPoint = CGPoint(x: 1, y: 0)
        lineGradientLayer.endPoint = CGPoint(x: 0, y: 0)
        lineGradientLayer.frame = CGRect(x: 11, y: contentView.height.double, width: widthConstant, height: 1.0)
        lineGradientLayer.insertSublayer(roundGradintLayer, at: 0)
        
        if let oldLineGradientLayer = oldLineGradientLayer {
            contentView.layer.replaceSublayer(oldLineGradientLayer, with: lineGradientLayer)
        } else {
            contentView.layer.insertSublayer(lineGradientLayer, at: 0)
        }
        
        oldLineGradientLayer = lineGradientLayer
    }
    
    //MARK: - UI Elements
    private let taskTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let taskTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.tintColor = .white
        //label.font = UIFont(name: "EuclidCircularA-Medium", size: 13)
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private let taskTimeLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.039, green: 0.051, blue: 0.141, alpha: 1)
        return view
    }()
    
    private let taskTimeLeftImageView = UIImageView(image: UIImage(named: "timer"))
    
    private let taskTimeLeftLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.text = ""
        return label
    }()
    
    private let taskTimeLeftLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let repeatButton = UIButton(type: .custom)
    
    //MARK: - Configure UI
    func configureUI() {
        contentView.cornerRadius = 11
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor(hexString: "#15183C")?.cgColor
        contentView.layer.masksToBounds = false
        contentView.tintColor = .white
        
        contentView.addSubview(taskTypeImageView)
        taskTypeImageView.anchorCenterYToSuperview()
        taskTypeImageView.anchor(left: contentView.leftAnchor, leftConstant: 8, widthConstant: 20, heightConstant: 20)
        
        contentView.addSubview(taskTimeLeftView)
        taskTimeLeftView.anchorCenterYToSuperview()
        taskTimeLeftView.anchor(right: contentView.rightAnchor, rightConstant: 15, widthConstant: 86, heightConstant: 30)
        taskTimeLeftView.cornerRadius = 15
        
        taskTimeLeftView.addSubview(taskTimeLeftImageView)
        taskTimeLeftImageView.anchorCenterYToSuperview()
        taskTimeLeftImageView.anchor(left: taskTimeLeftView.leftAnchor, leftConstant: 10, widthConstant: 13, heightConstant: 13)
        
        taskTimeLeftView.addSubview(taskTimeLeftLabel)
        taskTimeLeftLabel.anchorCenterYToSuperview()
        taskTimeLeftLabel.anchor(left: taskTimeLeftImageView.rightAnchor, right: taskTimeLeftView.rightAnchor, leftConstant: 3, rightConstant: 10, widthConstant: 40)
        
        contentView.addSubview(taskTextLabel)
        taskTextLabel.anchorCenterYToSuperview()
        taskTextLabel.anchor(left: taskTypeImageView.rightAnchor, right: taskTimeLeftView.leftAnchor, leftConstant: 8, rightConstant: 8)
        
        
        repeatButton.setImage(UIImage(named: "refresh-circle")?.original, for: .normal)
        repeatButton.backgroundColor = Style.blueRibbon
        repeatButton.cornerRadius = 15
        
        let attributedTitle = NSAttributedString(string: "Repeat",
                                                 attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11, weight: .semibold)])
        repeatButton.setAttributedTitle(attributedTitle , for: .normal)
        
        repeatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4);
        repeatButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0);
        
        contentView.addSubview(repeatButton)
        repeatButton.anchorCenterYToSuperview()
        repeatButton.anchor(right: contentView.rightAnchor, rightConstant: 15, widthConstant: 86, heightConstant: 30)
    }
    
    //MARK: - Bind to ViewModel
    func bindToViewModel(viewModel: TaskListCollectionViewCellModel){
        self.viewModel = viewModel
        
        configureUI()
        
        delegate = viewModel
        
        viewModel.taskTextOutput.bind(to: taskTextLabel.rx.text).disposed(by: disposeBag)
        viewModel.taskTimeLeftTextOutput.bind(to: taskTimeLeftLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.timeLeftPercentOutput.bind{ [weak self] percent in
            guard let self = self else { return }
            guard let percent = percent else { return }
            let widthConstant = max(percent * (self.contentView.frame.width.double - 22),0)
            
            if self.viewModel.task.value?.status == .created {
                self.configurelineLayout(widthConstant: widthConstant)
                self.repeatButton.isHidden = percent > 0
            } else {
                self.configurelineLayout(widthConstant: 0)
                self.repeatButton.isHidden = false
            }
        }.disposed(by: disposeBag)
        
        viewModel.taskTypeOutput.bind { [weak self] type in
            guard let self = self else { return }
            self.taskTypeImageView.image = type?.image
        }.disposed(by: disposeBag)
        
        repeatButton.rx.tapGesture().when(.recognized).bind{ _ in
            self.viewModel.repeatButtonClick() }.disposed(by: disposeBag)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        contentView.layer.borderColor = UIColor.white.cgColor
        
    }
}


