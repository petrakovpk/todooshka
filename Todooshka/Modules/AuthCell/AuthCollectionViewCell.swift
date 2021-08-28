//
//  AuthCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 25.08.2021.
//


import UIKit
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class AuthCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: AuthCollectionViewCellModel!
    
    static var reuseID: String = "AuthCollectionViewCell"
    
    //MARK: - UI Elements
    private lazy var textField = TDAuthTextField(customPlaceholder: "", imageName: "")
    
    //MARK: - Bind to ViewModel
    func bindToViewModel(viewModel: AuthCollectionViewCellModel){
        self.viewModel = viewModel
        
        textField = TDAuthTextField(customPlaceholder: viewModel.placeholder, imageName: viewModel.imageName)
        
        configureUI()
        
    }
    
    //MARK: - Configure UI
    func configureUI() {
        textField.cornerRadius = 13
        
        contentView.addSubview(textField)
        textField.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, leftConstant: 0, rightConstant: 0)
    }
    
    //MARK: - Colors
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}



