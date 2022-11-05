//
//  UIVIew.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.06.2021.
//
import UIKit

extension UIView {

    public func removeAllConstraints() {
        var oldSuperview = self.superview

        while let superview = oldSuperview {
            for constraint in superview.constraints {

                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

          oldSuperview = superview.superview
        }

        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}
