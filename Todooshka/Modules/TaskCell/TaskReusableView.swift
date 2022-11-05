//
//  TaskReusableView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.08.2021.
//

import UIKit

class TaskReusableView: UICollectionReusableView {

    static var reuseID: String = "TaskListReusableView"

    private let sectionHeaderLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(sectionHeaderLabel)
        sectionHeaderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)

        sectionHeaderLabel.textAlignment = .left
        sectionHeaderLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String) {
        sectionHeaderLabel.text = text
    }
}
