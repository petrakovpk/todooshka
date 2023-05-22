//
//  SettingsCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import UIKit

class SettingsCell: UITableViewCell {
  static var reuseID: String = "SettingsCell"

  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func setupUI() {
    layer.borderWidth = 0
    
    backgroundColor = .clear
    cornerRadius = height / 2
    
    imageView?.tintColor = Style.App.text
    textLabel?.textColor = Style.App.text
  }
  
  func configure(item: SettingItem) {
    imageView?.image = item.type.image.template
    textLabel?.text = item.text
  }
}
