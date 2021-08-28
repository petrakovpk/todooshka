//
//  TaskTypesTableViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.08.2021.
//

import UIKit

class TaskTypesTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    static var reuseID: String = "TaskTypesTableViewCell"
    
    //MARK: - Configure
    func configure(with type: TaskType) {
       
        backgroundColor = UIColor(hexString: "#0a0b1e")
        cornerRadius = height / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.094, green: 0.106, blue: 0.235, alpha: 1).cgColor
        
        imageView?.image = type.image
        imageView?.tintColor = .white
        textLabel?.text = type.text
    }
    
}
