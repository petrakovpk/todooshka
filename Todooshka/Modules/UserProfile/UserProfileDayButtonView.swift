//
//  UserProfileDayButtonView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 23.06.2021.
//

import UIKit

class UserProfileDayButtonView: UIView {
    // MARK: - UI Elements
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private let completedTasksLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ConfigureUI
    func configureUI(userDay: UserDay) {
        layer.cornerRadius = 15
        borderColor = .black
        borderWidth = 0.5

        dateLabel.text = userDay.date.dateString()
        statusLabel.text = userDay.dateStatus
        userImageView.image = userDay.dateImage

        addSubview(userImageView)
        userImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, topConstant: 2, leftConstant: 2, bottomConstant: 2, widthConstant: 50)

        let stackView = UIStackView(arrangedSubviews: [dateLabel, statusLabel, completedTasksLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: userImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 2, leftConstant: 2, bottomConstant: 2, rightConstant: 2)
    }

    // MARK: - Colors
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        /// Border color is not automatically catched by trait collection changes. Therefore, update it here.
        layer.borderColor = TDStyle.Colors.invertedBackgroundColor.cgColor
    }
}
