//
//  TDTaskCommentTextView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.
//

import UIKit

class TDTaskCommentTextView: UITextView {
  
  //MARK: - Properties
  var isEmpty = true
  
  //MARK: - Draw
  //    override func draw(_ rect: CGRect) {
  //        let bottomBorderLine = CALayer()
  //        bottomBorderLine.frame = CGRect(x: 0, y: bounds.height.int, width: bounds.width.int, height: 1)
  //        bottomBorderLine.backgroundColor = UIColor(red: 0.094, green: 0.105, blue: 0.233, alpha: 1).cgColor
  //        layer.addSublayer(bottomBorderLine)
  //    }
  
  //MARK: - Init
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    borderWidth = 0
    backgroundColor = UIColor.clear
    clipsToBounds = false
    font = UIFont.systemFont(ofSize: 13, weight: .medium)
    textColor = UIColor(named: "taskPlaceholderText")
    text = "Напишите комментарий"
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
}
