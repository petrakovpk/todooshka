//
//  ModuleColors.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 21.04.2022.
//
import UIKit

struct Theme {
  
  // App
  struct App {
    static let background = Palette.DualColors.Selago_235_235_252_Haiti_8_10_32
    static let text = Palette.DualColors.BlackPearl_White
    static let textInverted = Palette.DualColors.White_BlackPearl
    static let placeholder = Palette.DualColors.Martinique_a30_Martinique
    
    struct Header {
      static let background = Palette.DualColors.TitanWhite_228_229_254_Haiti_17_20_52
      static let dividerBackground = Palette.DualColors.HawkesBlue_Haiti_7_9_30
    }
    
    struct Buttons {
      struct RoundButton {
        static let background = Palette.DualColors.BlackPearl_White?.withAlphaComponent(0.1)
        static let tint = Palette.DualColors.BlackPearl_White
      }
    }
  }
  
  // Onboarding
  struct Onboarding {
    static let dotBackground = Palette.DualColors.PeriwinkleGray_Fiord
    static let text = Palette.SingleColors.SantasGray
  }
  
  // TabBar
  struct TabBar {
    static let background = Palette.DualColors.Snuff_Haiti_18_22_55
    static let selected = Palette.DualColors.BlueRibbon_White
    static let unselected = Palette.DualColors.BlackPearl_a50_White_a30
  }
  
  // MainTaskList
  struct MainTaskList {
    static let buttonBackground = Palette.DualColors.TitanWhite_228_229_254_Haiti_17_20_52
  }
  
  // TaskList
  struct TaskList {
    struct Cell {
      static let descriptionText = Palette.DualColors.BlackPearl_a60_White_a60
      static let timeLeftViewBackground = Palette.DualColors.BlueBayoux_Haiti_10_13_36
    }
  }
  
  // Task
  struct Task {
    struct TypeLargeCollectionViewCell {
      static let selectedText = UIColor.white
      static let selectedTint = UIColor.white
      static let selectedBackground = Palette.SingleColors.BlueRibbon
      static let unselectedBackground = Palette.DualColors.White_BlackPearl
    }
  }
  
  struct TaskType {
    // Cell
    struct Cell {
      static let background = Palette.DualColors.TitanWhite_244_245_255_Haiti_16_18_54
      static let border = Palette.DualColors.Periwinkle_PortGore
    }
  }
  
  struct UserProfile {
    struct Calendar {
      static let background = Palette.DualColors.Selago_PortGore
      static let divider = Palette.DualColors.MoonRaker_PortGore
      
      struct Cell {
        static let border = Palette.SingleColors.BlueRibbon
        static let selectedBackground = Palette.SingleColors.BlueRibbon
      }
    }
  }
  
  struct GameCurrency {
    static let textViewBackground = Palette.DualColors.TitanWhite_228_229_254_Haiti_17_20_52
  }
  
  // Bird
  struct Bird {
    struct TypeSmallCollectionViewCell {
      static let selectedText = UIColor.black
      static let selectedTint = UIColor.black
      static let selectedBackground = Palette.SingleColors.Shamrock
      static let unselectedBackground = Palette.DualColors.White_BlackPearl
    }
  }
  
  

  
  // Alert
  struct BuyAlertView {
    static let width = UIScreen.main.bounds.width * 2 / 3
    static let height = UIScreen.main.bounds.height / 3
    static let background = UIColor.black.withAlphaComponent(0.5)
    
    struct eggImageView {
      static let width = Theme.BuyAlertView.width / 4
      static let height = Theme.BuyAlertView.eggImageView.width * 1.3
      static let topConstant = (Theme.BuyAlertView.width / 2 - Theme.BuyAlertView.eggImageView.width) / 2
      static let leftConstant = (Theme.BuyAlertView.width / 2 - Theme.BuyAlertView.eggImageView.width) / 2 + 16
    }
    
    struct birdImageView {
      static let width = Theme.BuyAlertView.width / 4
      static let height = Theme.BuyAlertView.eggImageView.width * 1.3
      static let topConstant = (Theme.BuyAlertView.width / 2 - Theme.BuyAlertView.eggImageView.width) / 2
      static let rightConstant = (Theme.BuyAlertView.width / 2 - Theme.BuyAlertView.eggImageView.width) / 2 + 16
    }
    
    struct cancelButton {
      static let width = Theme.BuyAlertView.width / 2 - 16 - 8
      static let height = 50
    }
    
    struct buyButton {
      static let width = Theme.BuyAlertView.width / 2 - 16 - 8
      static let height = 50
    }
  }
  
  struct Scene {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.width * UIImage(named: "день01")!.size.height / UIImage(named: "день01")!.size.width * 1.5
    static let scale = UIScreen.main.bounds.width / UIImage(named: "день01")!.size.width
    
    struct Egg {
      static let scale = UIScreen.main.bounds.width / UIImage(named: "день01")!.size.width / 1.5
    }
  }
}

