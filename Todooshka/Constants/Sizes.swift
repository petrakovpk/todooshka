//
//  Sizes.swift
//  Todooshka
//
//  Created by Pavel Petakov on 15.10.2022.
//

import UIKit

struct Sizes {
  
  struct App {
    static let developerWidth: CGFloat = 428
    static let developerHeight: CGFloat = 896
    
    static var widthRatio: CGFloat {
      UIScreen.main.bounds.width / Sizes.App.developerWidth
    }
    
    static var heightRatio: CGFloat {
      UIScreen.main.bounds.height / Sizes.App.developerHeight
    }
  }
  
  struct Buttons {

    struct alertBuyBirdButton {
      static let width = (Sizes.Views.alertBuyBirdView.width / 2 - 16 - 8).adjustByWidth
      static let height = 48.adjustByHeight
    }
    
    struct alertDeleteButton {
      static let width = 94.adjustByWidth
      static let height = 30.adjustByHeight
    }
    
    struct alertOkButton {
      static let width = 94.adjustByWidth
      static let height = 30.adjustByHeight
    }
    
    struct alertWillWaitButton {
      static let width = 120.adjustByWidth
      static let height = 30.adjustByHeight
    }
    
    struct appButton {
      static let height = 48.adjustByHeight
    }
    
    struct calendarShopButton {
      static let height = 40.adjustByHeight
    }
    
    struct calendarSettingsButton {
      static let width = 40.adjustByHeight
      static let height = 40.adjustByHeight
    }
    
    struct planedButton {
      static let width = 100.adjustByWidth
      static let height = 40.adjustByHeight
    }
    
    struct skipButton {
      static let width = 76.adjustByWidth
    }
  }
  
  struct Cells {
    struct BirdCell {
      static let width = 76.adjustByHeight
      static let height = 76.adjustByHeight
    }
    struct CalendarCell {
      static let width = min(45.adjustByHeight, 45.adjustByWidth)
      static let height = min(45.adjustByHeight, 45.adjustByWidth)
    }
    struct ColorCell {
      static let width = 48.adjustByHeight
      static let height = 48.adjustByHeight
    }
    struct IconCell {
      static let width = 62.adjustByHeight
      static let height = 62.adjustByHeight
    }
    struct KindOfTaskCell {
      static let width = 90.adjustByHeight
      static let height = 91.adjustByHeight
    }
  }
  
  struct ImageViews {
    struct alertEggImageView {
      static let width = (Sizes.Views.alertBuyBirdView.width / 4).adjustByWidth
      static let height = (Sizes.ImageViews.alertEggImageView.width * 1.3).adjustByHeight
      static let TopConstant = 20.adjustByHeight
      static let LeftConstant = ((Sizes.Views.alertBuyBirdView.width / 2 - Sizes.ImageViews.alertEggImageView.width) / 2 + 16).adjustByWidth
    }
    
    struct alertBirdImageView {
      static let width = (Sizes.Views.alertBuyBirdView.width / 4).adjustByWidth
      static let height = (Sizes.ImageViews.alertBirdImageView.width * 1.3).adjustByHeight
      static let TopConstant = 20.adjustByHeight
      static let RightConstant = ((Sizes.Views.alertBuyBirdView.width / 2 - Sizes.ImageViews.alertBirdImageView.width) / 2 + 16).adjustByWidth
    }
    
    struct birdImageView {
      static let width = 200.adjustByWidth
      static let height = 200.adjustByHeight
    }
  }
  
  struct Labels {
    struct onboardingHeaderLabel {
      static let bottomConstant = 80.adjustByWidth
    }
  }
  
  struct Views {

    struct alertBuyBirdView {
      static let width = (UIScreen.main.bounds.width * 2 / 3).adjustByWidth
      static let height = (UIScreen.main.bounds.height / 3).adjustByHeight
    }
    
    struct alertDeleteView {
      static let width = 287.adjustByWidth
      static let height = 171.adjustByWidth
    }
    
    struct alertLogOutView {
      static let width = 287.adjustByWidth
      static let height = 171.adjustByWidth
    }
    
    struct animationView {
      static let height = 222.0.adjustByHeight
    }
    
    struct Calendar {
      static let headerSizeHeight = min(25.adjustByHeight, 25.adjustByWidth)
      static let minimumLineSpacing = min(8.0.adjustByHeight, 8.0.adjustByWidth)
      static let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: min(12.adjustByHeight, 12.adjustByWidth), right: 0)
    }
    
    struct Dot {
      static let bottomConstant = 74.adjustByWidth
    }
    
    struct KindsOfTaskCollectionView {
      static let height = 100.adjustByHeight
    }
    
    struct KindsOfTaskContainerView {
      static let height = 68.adjustByWidth
      static let width = 68.adjustByWidth
    }
    
    struct Header {
      static let height = 55.adjustByHeight
    }
  }
  
  struct TextFields {
    struct TDTaskTextField {
      static let heightConstant = 40.adjustByHeight
    }
  }
  
  struct TextViews {
    struct taskDescriptionTextView {
      static let height = 200.adjustByHeight
    }
    
    struct onboardingDescriptionTextView {
      static let bottomConstant = 100.adjustByHeight
      static let heightConstant = 90.adjustByHeight
    }
  }
}


extension CGFloat {
  var adjustByWidth: CGFloat {
    self * Sizes.App.widthRatio
  }
  var adjustByHeight: CGFloat {
    self * Sizes.App.heightRatio
  }
}

extension Double {
  var adjustByWidth: CGFloat {
    CGFloat(self) * Sizes.App.widthRatio
  }
  var adjustByHeight: CGFloat {
    CGFloat(self) * Sizes.App.heightRatio
  }
}

extension Int {
  var adjustByWidth: CGFloat {
    CGFloat(self) * Sizes.App.widthRatio
  }
  var adjustByHeight: CGFloat {
    CGFloat(self) * Sizes.App.heightRatio
  }
}
