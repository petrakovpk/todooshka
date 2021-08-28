//
//  UITextView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import UIKit

extension UITextView {

    func centerVerticalText() {
        self.textAlignment = .center
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}
