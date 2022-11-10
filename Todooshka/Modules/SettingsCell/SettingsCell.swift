//
//  SettingsCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import UIKit

class SettingsCell: UITableViewCell {
  // MARK: - Properties
  static var reuseID: String = "UserProfileSettingsCell"

  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(imageName: String, text: String ) {
    backgroundColor = .clear
    cornerRadius = height / 2
    layer.borderWidth = 0

    imageView?.image = UIImage(named: imageName)?.template
    imageView?.tintColor = Style.App.text
    textLabel?.text = text
    textLabel?.textColor = Style.App.text
  }
}
