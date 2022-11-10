//
//  OverdueTaskCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 16.06.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class OverdueTaskCollectionViewCell: SwipeCollectionViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: OverdueTaskCollectionViewCellModel!

    static var reuseID: String = "OverdueTaskCollectionViewCell"

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

    private let addTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("В работу", for: .normal)
        return button
    }()

    // MARK: - Configure UI
    func configureUI() {
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 20
        contentView.layer.borderColor = TDStyle.Colors.invertedBackgroundColor.cgColor

        contentView.addSubview(taskTypeImageView)
        taskTypeImageView.anchorCenterYToSuperview()
        taskTypeImageView.anchor(left: contentView.leftAnchor, leftConstant: 8, widthConstant: 20, heightConstant: 20)

        contentView.addSubview(addTaskButton)
        addTaskButton.anchorCenterYToSuperview()
        addTaskButton.anchor(right: contentView.rightAnchor, rightConstant: 8, widthConstant: 80)

        contentView.addSubview(taskTextLabel)
        taskTextLabel.anchorCenterYToSuperview()
        taskTextLabel.anchor(left: taskTypeImageView.rightAnchor, right: addTaskButton.leftAnchor, leftConstant: 8, rightConstant: 8)
    }

    func bindToViewModel(viewModel: OverdueTaskCollectionViewCellModel) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()

        delegate = viewModel

        configureUI()

        addTaskButton.rx.tap.bind { viewModel.addTaskButtonClick() }.disposed(by: disposeBag)

        viewModel.task.bind { [weak self] task in
            guard let self = self else {return }
            guard let task = task else { return }
            self.taskTextLabel.text = task.text
            self.taskTypeImageView.image = task.taskType?.image
        }.disposed(by: disposeBag)
    }
}
