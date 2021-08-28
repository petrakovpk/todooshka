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
    
    //MARK: - Configure UI
    func configureUI() {
        contentView.cornerRadius = bounds.width / 2
        contentView.backgroundColor = UIColor.clear
        
        contentView.addSubview(dateLabel)
        dateLabel.anchorCenterXToSuperview()
        dateLabel.anchorCenterYToSuperview()
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
    func bindToViewModel(viewModel: UserProfileDayCollectionViewCellModel) {
        self.viewModel = viewModel
        
        configureUI()
        
        disposeBag = DisposeBag()
        viewModel.calendarDay.bind{ [weak self] calendarDay in
            guard let self = self else { return }
            guard let calendarDay = calendarDay else { return }
            self.dateLabel.text = calendarDay.date.day.string

            if calendarDay.isSelectedMonth {
                self.dateLabel.alpha = 1
            } else {
                self.dateLabel.alpha = 0.4
            }
        }.disposed(by: disposeBag)
        
        viewModel.isSelectedDay.bind{ [weak self] isSelectedDay in
            guard let self = self else { return }
            if isSelectedDay {
                self.contentView.backgroundColor = Style.blueRibbon
            } else {
                self.contentView.backgroundColor = UIColor.clear
            }
        }.disposed(by: disposeBag)
      
        viewModel.isToday.bind{ [weak self] isToday in
            guard let self = self else { return }
            if isToday {
                self.contentView.borderWidth = 1
                self.contentView.borderColor = Style.blueRibbon
            } else {
                self.contentView.borderWidth = 0
            }
        }.disposed(by: disposeBag)
        
        viewModel.roundViewCount.bind{ [weak self] count in
            guard let self = self else { return }
            
            if self.roundView1.superview != nil {
                self.roundView1.removeFromSuperview()
            }
            
            if self.roundView2.superview != nil {
                self.roundView2.removeFromSuperview()
            }
            
            if self.roundView3.superview != nil {
                self.roundView3.removeFromSuperview()
            }
            
            switch count {
            case 1:
                self.configureOneRound()
            case 2:
                self.configureTwoRounds()
            case 3:
                self.configureThreeRounds()
            default:
                return
            }
        }.disposed(by: disposeBag)
    }
}

