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
  private var roundsBackground = UIView()
  
  //  private let firstRound = UIView()
  //  private let secondRound = UIView()
  //  private let thirdRound = UIView()
  //
  private let oneRoundView: UIView = {
    let view = UIView()
    let roundView = UIView()
    roundView.cornerRadius = 2
    
    view.addSubview(roundView)
    roundView.anchor(widthConstant: 4, heightConstant: 4)
    roundView.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
    return view
  }()
  
    private let twoRoundsView: UIView = {
      let view = UIView()
      let firstRoundView = UIView()
      firstRoundView.cornerRadius = 2
  
      view.addSubview(firstRoundView)
      firstRoundView.anchor(left: view.leftAnchor, widthConstant: 4, heightConstant: 4)
      firstRoundView.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
      
      let secondRoundView = UIView()
      secondRoundView.cornerRadius = 2
      
      view.addSubview(secondRoundView)
      secondRoundView.anchor(left: firstRoundView.rightAnchor, widthConstant: 4, heightConstant: 4)
      secondRoundView.backgroundColor = UIColor(red: 0.169, green: 0.718, blue: 0.486, alpha: 1)
      
      return view
    }()
  
    private let threeRoundsView: UIView = {
      let view = UIView()
      let firstRoundView = UIView()
      firstRoundView.cornerRadius = 2
  
      view.addSubview(firstRoundView)
      firstRoundView.anchor(left: view.leftAnchor, widthConstant: 4, heightConstant: 4)
      firstRoundView.backgroundColor = UIColor(red: 0.349, green: 0.851, blue: 0.639, alpha: 1)
      
      let secondRoundView = UIView()
      secondRoundView.cornerRadius = 2
      
      view.addSubview(secondRoundView)
      secondRoundView.anchor(left: firstRoundView.rightAnchor, widthConstant: 4, heightConstant: 4)
      secondRoundView.backgroundColor = UIColor(red: 0.169, green: 0.718, blue: 0.486, alpha: 1)
      
      let thirdRoundView = UIView()
      thirdRoundView.cornerRadius = 2
      
      view.addSubview(thirdRoundView)
      thirdRoundView.anchor(left: secondRoundView.rightAnchor, widthConstant: 4, heightConstant: 4)
      thirdRoundView.backgroundColor = UIColor(red: 0.07, green: 0.512, blue: 0.326, alpha: 1)
      
      return view
    }()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    configureUI()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  //MARK: - Configure UI
  func configureUI() {
    contentView.cornerRadius = bounds.width / 2
    contentView.layer.borderColor = UIColor.blueRibbon.cgColor
    
    contentView.addSubview(dateLabel)
    dateLabel.anchorCenterXToSuperview()
    dateLabel.anchorCenterYToSuperview()
    
    contentView.addSubview(oneRoundView)
    oneRoundView.anchor(top: dateLabel.bottomAnchor, topConstant: 5, widthConstant: 4, heightConstant: 4)
    oneRoundView.anchorCenterXToSuperview()
    
    contentView.addSubview(twoRoundsView)
    twoRoundsView.anchor(top: dateLabel.bottomAnchor, topConstant: 5, widthConstant: 2 * 4, heightConstant: 4)
    twoRoundsView.anchorCenterXToSuperview()
    
    contentView.addSubview(threeRoundsView)
    threeRoundsView.anchor(top: dateLabel.bottomAnchor, topConstant: 5, widthConstant: 3 * 4, heightConstant: 4)
    threeRoundsView.anchorCenterXToSuperview()
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
    output.firstRoundIsHidden.drive(oneRoundView.rx.isHidden).disposed(by: disposeBag)
    output.secondRoundIsHidden.drive(twoRoundsView.rx.isHidden).disposed(by: disposeBag)
    output.thirdRoundIsHidden.drive(threeRoundsView.rx.isHidden).disposed(by: disposeBag)
  }
  
}

