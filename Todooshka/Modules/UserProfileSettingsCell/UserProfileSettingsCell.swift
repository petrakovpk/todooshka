//
//  UserProfileSettingsCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import UIKit

class UserProfileSettingsCell: UITableViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "UserProfileSettingsCell"
  
  //MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - Configure
  func configure(imageName: String, text: String ) {
    
    backgroundColor = .clear
    cornerRadius = height / 2
    layer.borderWidth = 0
    //layer.borderColor = UIColor(red: 0.094, green: 0.106, blue: 0.235, alpha: 1).cgColor
    
    imageView?.image = UIImage(named: imageName)?.template
    imageView?.tintColor = UIColor(named: "appText")
    textLabel?.text = text
    textLabel?.textColor =  UIColor(named: "appText")
  }
  
}


