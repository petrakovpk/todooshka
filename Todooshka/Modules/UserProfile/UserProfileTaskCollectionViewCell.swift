//
//  UserProfileTaskCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class UserProfileTaskCollectionViewCell: SwipeCollectionViewCell {
    // MARK: - Properties
    var viewModel: UserProfileTaskCollectionViewCellModel!
    var disposeBag = DisposeBag()

    static var reuseID: String = "UserProfileTaskCollectionViewCell"

    // MARK: - UI Elements
    private let taskTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let taskTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    // MARK: - Configure UI
    func configureUI() {
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 20
        contentView.layer.borderColor = UIColor.systemGreen.cgColor

        contentView.addSubview(taskTypeImageView)
        taskTypeImageView.anchorCenterYToSuperview()
        taskTypeImageView.anchor(left: contentView.leftAnchor, leftConstant: 8, widthConstant: 20, heightConstant: 20)

        contentView.addSubview(taskTextLabel)
        taskTextLabel.anchorCenterYToSuperview()
        taskTextLabel.anchor(left: taskTypeImageView.rightAnchor, right: contentView.rightAnchor, leftConstant: 8, rightConstant: 8)
    }

    func bindToViewModel(viewModel: UserProfileTaskCollectionViewCellModel) {
        self.viewModel = viewModel

        delegate = viewModel

        configureUI()

        viewModel.taskRelay.bind { [unowned self] task in
            taskTextLabel.text = task?.text
            taskTypeImageView.image = task?.typeImage
        }.disposed(by: disposeBag)
    }
}
