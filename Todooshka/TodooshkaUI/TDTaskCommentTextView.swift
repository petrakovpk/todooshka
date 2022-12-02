//
//  TDTaskCommentTextView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.
//

import UIKit

class TDTaskCommentTextView: UITextView {
  // MARK: - Init
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    backgroundColor = UIColor.clear
    borderWidth = 0
    clipsToBounds = false
    font = UIFont.systemFont(ofSize: 13, weight: .medium)
    text = "Напишите комментарий"
    textColor = Style.App.placeholder
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
