//
//  UserProfileDayCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.06.2021.
//


import UIKit
import RxSwift
import RxCocoa
import Foundation

class UserProfileDayCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "UserProfileDayCollectionViewCell"
  
  var viewModel: UserProfileDayCollectionViewCellModel!
  var disposeBag = DisposeBag()
  
  //MARK: - UI Elements
  private let dateLabel = UILabel()
  private let roundView1 = UIView()
  private let roundView2 = UIView()
  private let roundView3 = UIView()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    configureUI()
    //bindViewModel()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    contentView.cornerRadius = bounds.width / 2
    contentView.layer.borderColor = UIColor.blueRibbon.cgColor
    
    contentView.addSubview(dateLabel)
    dateLabel.anchorCenterXToSuperview()
    dateLabel.anchorCenterYToSuperview()
  }
  
  func configureNoRound() {
    if self.roundView1.superview != nil {
      self.roundView1.removeFromSuperview()
    }
    
    if self.roundView2.superview != nil {
      self.roundView2.removeFromSuperview()
    }
    
    if self.roundView3.superview != nil {
      self.roundView3.removeFromSuperview()
    }
  }
  
  func configureOneRound() {
    roundView1.cornerRadius = 2
    contentView.addSubview(roundView1)
    roundView1.anchor(top: dateLabel.bottomAnchor, topConstant: 5, widthConstant: 4, heightConstant: 4)
    roundView1.anchorCenterXToSuperview()
    
    roundView1.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
  }
  
  func configureTwoRounds() {
    roundView1.cornerRadius = 2
    contentView.addSubview(roundView1)
    roundView1.anchor(top: dateLabel.bottomAnchor, topConstant: 5, widthConstant: 4, heightConstant: 4)
    roundView1.anchorCenterXToSuperview(constant: 2)
    
    roundView2.cornerRadius = 2
    contentView.addSubview(roundView2)
    roundView2.anchor(top: roundView1.topAnchor, right: roundView1.leftAnchor, widthConstant: 4, heightConstant: 4)
    
    roundView1.backgroundColor = UIColor(red: 0.169, green: 0.718, blue: 0.486, alpha: 1)
    roundView2.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
  }
  
  func configureThreeRounds() {
    roundView1.cornerRadius = 2
    contentView.addSubview(roundView1)
    roundView1.anchor(top: dateLabel.bottomAnchor, topConstant: 5, widthConstant: 4, heightConstant: 4)
    roundView1.anchorCenterXToSuperview()
    
    roundView2.cornerRadius = 2
    contentView.addSubview(roundView2)
    roundView2.anchor(top: roundView1.topAnchor, right: roundView1.leftAnchor, widthConstant: 4, heightConstant: 4)
    
    roundView3.cornerRadius = 2
    contentView.addSubview(roundView3)
    roundView3.anchor(top: roundView1.topAnchor, left: roundView1.rightAnchor, widthConstant: 4, heightConstant: 4)
    
    roundView1.backgroundColor = UIColor(red: 0.169, green: 0.718, blue: 0.486, alpha: 1)
    roundView2.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
    roundView3.backgroundColor = UIColor(red: 0.07, green: 0.512, blue: 0.326, alpha: 1)
  }
  
  //MARK: - Bind
  func bindViewModel() {
    
    disposeBag = DisposeBag()
    
    let output = viewModel.transform()
    output.text.drive(dateLabel.rx.text).disposed(by: disposeBag)
    output.alpha.drive(dateLabel.rx.alpha).disposed(by: disposeBag)
    output.backgroundColor.drive(contentView.rx.backgroundColor).disposed(by: disposeBag)
    output.textColor.drive(dateLabel.rx.textColor).disposed(by: disposeBag)
    output.borderWidth.drive(contentView.rx.borderWidth).disposed(by: disposeBag)
    output.roundsCount.drive(roundsCountBinder).disposed(by: disposeBag)
  }
  
  var roundsCountBinder: Binder<Int> {
    return Binder(self, binding: { (cell, count) in
      cell.configureNoRound()
      if count == 1 { cell.configureOneRound() }
      if count == 2 { cell.configureTwoRounds() }
      if count == 3 { cell.configureThreeRounds() }
    })
  }
  
}

