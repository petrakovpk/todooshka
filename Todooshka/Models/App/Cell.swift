//
//  Cell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.07.2021.
//

import UIKit

class IndicatorView: UIView {
    var color = UIColor.clear {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        UIBezierPath(ovalIn: rect).fill()
    }
}

enum ActionDescriptor {
    case idea, trash, complete
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .idea: return "Идея"
        case .trash: return "Удалить"
        case .complete: return "Выполнено"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode, size: CGSize) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
    #if canImport(Combine)
        if #available(iOS 13.0, *) {
            let name: String
            switch self {
            case .idea: name = "lamp-charge"
            case .trash: name = "trash"
            case .complete: name = "tick"
            }
            
            if style == .backgroundColor {
                let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
                return UIImage(systemName: name, withConfiguration: config)
            } else {
                let image = UIImage(named: name)?.withTintColor(.white, renderingMode: .alwaysTemplate)
                return circularIcon(with: color(forStyle: style), size: size, icon: image)
            }
        }
    #else
        return UIImage(systemName: "xmark")
    #endif
       return nil
    }
    
    func color(forStyle style: ButtonStyle) -> UIColor {
        switch self {
        case .idea: return UIColor(red: 1, green: 0.36, blue: 0, alpha: 1)
        case .trash: return UIColor(red: 1, green: 0, blue: 0.36, alpha: 1)
        case .complete: return UIColor(red: 0.351, green: 0.85, blue: 0.64, alpha: 1)
        }
    }
    
    func circularIcon(with color: UIColor, size: CGSize, icon: UIImage? = nil) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        UIBezierPath(ovalIn: rect).addClip()

        color.setFill()
        UIRectFill(rect)

        if let icon = icon {
            let iconRect = CGRect(x: (rect.size.width - icon.size.width) / 2,
                                  y: (rect.size.height - icon.size.height) / 2,
                                  width: icon.size.width,
                                  height: icon.size.height)
            icon.draw(in: iconRect, blendMode: .normal, alpha: 1.0)
        }

        defer { UIGraphicsEndImageContext() }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}
