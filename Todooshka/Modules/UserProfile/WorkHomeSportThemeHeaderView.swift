//
//  WorkHomeSportThemeHeaderswift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 23.06.2021.
//

import UIKit

class WorkHomeSportThemeHeaderView: UIView {
    // MARK: - UI Elements
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let button1 = UIButton(type: .system)
    private let label12 = UILabel(text: "Спорт")
    private let button2 = UIButton(type: .system)
    private let label22 = UILabel(text: "Работа")
    private let button3 = UIButton(type: .system)
    private let label32 = UILabel(text: "Дом")
    private let button4 = UIButton(type: .system)
    private let label42 = UILabel(text: "Другое")

    var staskView1 = UIStackView()
    var staskView2 = UIStackView()
    var staskView3 = UIStackView()
    var staskView4 = UIStackView()

    // MARK: - Init
    init() {
        super.init(frame: .zero)

        addSubview(headerLabel)
        headerLabel.anchorCenterXToSuperview()
        headerLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor)

        label12.textAlignment = .center
        label22.textAlignment = .center
        label32.textAlignment = .center
        label42.textAlignment = .center

        label12.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label22.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label32.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label42.font = UIFont.systemFont(ofSize: 10, weight: .light)

        staskView1 = UIStackView(arrangedSubviews: [button1, button2], axis: .horizontal)
        staskView1.distribution = .fillEqually
        staskView2 = UIStackView(arrangedSubviews: [label12, label22], axis: .horizontal)
        staskView2.distribution = .fillEqually
        staskView3 = UIStackView(arrangedSubviews: [button3, button4], axis: .horizontal)
        staskView3.distribution = .fillEqually
        staskView4 = UIStackView(arrangedSubviews: [label32, label42], axis: .horizontal)
        staskView4.distribution = .fillEqually

        addSubview(staskView1)
        staskView1.anchor(top: headerLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, topConstant: 16, leftConstant: 5,        rightConstant: 5)

        addSubview(staskView2)
        staskView2.anchor(top: staskView1.bottomAnchor, left: leftAnchor, right: rightAnchor, topConstant: 5, leftConstant: 5,        rightConstant: 5)

        addSubview(staskView3)
        staskView3.anchor(top: staskView2.bottomAnchor, left: leftAnchor, right: rightAnchor, topConstant: 8, leftConstant: 5,        rightConstant: 5)

        addSubview(staskView4)
        staskView4.anchor(top: staskView3.bottomAnchor, left: leftAnchor, right: rightAnchor, topConstant: 5, leftConstant: 5,        rightConstant: 5)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure UI
    func configureUI(userDay: UserDay) {
        if userDay.date.isInToday {
            headerLabel.text = "Сегодня"
        } else {
            headerLabel.text = userDay.date.string(withFormat: "d MMMM").localized()
        }

//        let button1Text = userDay.closedTasks.count(where: { task in
//            return task.type == .sport
//        }).string
//        
//        let button2Text = userDay.closedTasks.count(where: { task in
//            return task.type == .work
//        }).string
//        
//        let button3Text = userDay.closedTasks.count(where: { task in
//            return task.type == .family
//        }).string
//        
//        let button4Text = userDay.closedTasks.count(where: { task in
//            return task.type == .shop
//        }).string

//        button1.setTitle(button1Text, for: .normal)
//        button2.setTitle(button2Text, for: .normal)
//        button3.setTitle(button3Text, for: .normal)
//        button4.setTitle(button4Text, for: .normal)
    }

    // MARK: - Colors
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        /// Border color is not automatically catched by trait collection changes. Therefore, update it here.
        layer.borderColor = TDStyle.Colors.invertedBackgroundColor.cgColor
    }
}
