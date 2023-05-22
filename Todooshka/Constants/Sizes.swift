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
    struct AlertBuyBirdButton {
      static let width = (Sizes.Views.AlertBuyBirdView.width / 2 - 16 - 8).adjustByWidth
      static let height = 48.adjustByHeight
    }
    
    struct AlertOkButton {
      static let width = 94.adjustByWidth
      static let height = 30.adjustByHeight
    }

    struct AlertWillWaitButton {
      static let width = 120.adjustByWidth
      static let height = 30.adjustByHeight
    }

    struct AppButton {
      static let height = 48.adjustByHeight
    }

    struct CalendarShopButton {
      static let height = 40.adjustByHeight
    }

    struct CalendarSettingsButton {
      static let width = 40.adjustByHeight
      static let height = 40.adjustByHeight
    }

    struct PlanedButton {
      static let width = 100.adjustByWidth
      static let height = 40.adjustByHeight
    }

    struct SkipButton {
      static let width = 76.adjustByWidth
    }
  }

  struct Cells {
    struct BirdCell {
      static let width = 76.adjustByHeight
      static let height = 76.adjustByHeight
    }
    struct CalendarCell {
      static let header = 20.adjustByHeight
      static let size = (UIScreen.main.bounds.width - 4 * 16 - 2 * 30) / 7
    }
    struct ColorCell {
      static let width = 48.adjustByHeight
      static let height = 48.adjustByHeight
    }
    struct IconCell {
      static let width = 62.adjustByHeight
      static let height = 62.adjustByHeight
    }
    struct KindCell {
      static let width = 90.adjustByHeight
      static let height = 91.adjustByHeight
    }
    struct ThemeCell {
      static let width = 120.adjustByHeight
      static let height = 120.adjustByHeight
    }
    struct ThemeTypeCell {
      static let width = 80.adjustByHeight
      static let height = 50.adjustByHeight
    }
    struct UserProfilePublicationCell {
      static let width = UIScreen.main.bounds.width / 3
      static let height = UIScreen.main.bounds.width / 2
    }
  }

  struct ImageViews {
    struct AlertEggImageView {
      static let width = (Sizes.Views.AlertBuyBirdView.width / 4).adjustByWidth
      static let height = (Sizes.ImageViews.AlertEggImageView.width * 1.3).adjustByHeight
      static let TopConstant = 20.adjustByHeight
      static let LeftConstant = ((Sizes.Views.AlertBuyBirdView.width / 2 - Sizes.ImageViews.AlertEggImageView.width) / 2 + 16).adjustByWidth
    }

    struct AlertBirdImageView {
      static let width = (Sizes.Views.AlertBuyBirdView.width / 4).adjustByWidth
      static let height = (Sizes.ImageViews.AlertBirdImageView.width * 1.3).adjustByHeight
      static let TopConstant = 20.adjustByHeight
      static let RightConstant = ((Sizes.Views.AlertBuyBirdView.width / 2 - Sizes.ImageViews.AlertBirdImageView.width) / 2 + 16).adjustByWidth
    }

    struct BirdImageView {
      static let width = 200.adjustByWidth
      static let height = 200.adjustByHeight
    }

    struct DragonImageView {
      static let height = 300.adjustByHeight
    }
  }

  struct Labels {
    struct OnboardingHeaderLabel {
      static let bottomConstant = 80.adjustByWidth
    }
  }

  struct Views {
    struct AlertBuyBirdView {
      static let width = (UIScreen.main.bounds.width * 2 / 3).adjustByWidth
      static let height = (UIScreen.main.bounds.height / 3).adjustByHeight
    }

    struct AlertDeleteView {
      static let width = 287.adjustByWidth
      static let height = 171.adjustByWidth
    }

    struct AlertLogOutView {
      static let width = 287.adjustByWidth
      static let height = 171.adjustByWidth
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
    struct TaskDescriptionTextView {
      static let height = 150.adjustByHeight
    }

    struct OnboardingDescriptionTextView {
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
