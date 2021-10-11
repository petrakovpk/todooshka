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
