//
//  PlaceholderTextView.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import UIKit

class PlaceholderTextView: UITextView {

    // MARK: - Properties
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    var placeholderColor: UIColor? {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }

    public var placeholderLabel: UILabel!

    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlaceholderLabel()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholderLabel()
    }

    // MARK: - Setup
    private func setupPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        placeholderLabel.textColor = Style.App.placeholder
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            placeholderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }

    // MARK: - Actions
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
}

