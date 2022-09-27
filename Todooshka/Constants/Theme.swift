//
//  ModuleColors.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 21.04.2022.
//
import UIKit

struct Theme {
  
  struct App {
    static let background = Palette.DualColors.TitanWhite_235_236_255_Haiti_10_12_35
    static let text = Palette.DualColors.BlackPearl_White
    static let textInverted = Palette.DualColors.White_BlackPearl
    static let placeholder = Palette.DualColors.Martinique_a30_Martinique
  }
  
  struct Auth {
    static let Background = Palette.DualColors.TitanWhite_235_236_255_BlackPerl_3_4_16
  }
  
  struct Buttons {
    struct OverduedOrIdea {
      static let Background = Palette.DualColors.Selago_220_222_251_PortGore_26_29_67
    }
    struct NextButton {
      static let EnabledBackground = Palette.SingleColors.BlueRibbon
      static let DisabledBackground = Palette.DualColors.Mischka_205_205_223_Mirage_23_25_51
    }
    struct RoundButton {
      static let background = Palette.DualColors.BlackPearl_White?.withAlphaComponent(0.1)
      static let tint = Palette.DualColors.BlackPearl_White
    }
  }
  
  struct Divider {
    static let selected = Palette.SingleColors.BlueRibbon
    static let unselected = Palette.DualColors.Selago_220_222_251_PortGore_26_29_67
    static let selectedText = Theme.App.text
    static let unselectedText = Palette.DualColors.Wistful_169_171_217_EastBay_81_85_132
  }
  
  struct Header {
    static let Background = Palette.DualColors.TitanWhite_228_229_254_Haiti_7_9_30
    static let Divider = Palette.DualColors.Periwinkle_204_206_253_Haiti_17_20_52
  }
  
  struct Onboarding {
    static let dotBackground = Palette.DualColors.PeriwinkleGray_Fiord
    static let text = Palette.SingleColors.SantasGray
  }
  
  struct TextFields {
    struct AuthTextField {
      static let Background = Palette.DualColors.TitanWhite_224_226_255_Haiti_10_12_35
      static let Border = Palette.DualColors.HawkesBlue_196_200_251_Martinique_45_48_80
    }
    struct SettingsTextField {
      static let Background = Palette.DualColors.TitanWhite_224_226_255_PortGore_26_29_67
      static let Border = Palette.DualColors.HawkesBlue_196_200_251_Martinique_45_48_80
      static let Tint = Palette.DualColors.HawkesBlue_196_200_251_Martinique_45_48_80
    }
  }
  
  struct TabBar {
    static let Background = Palette.DualColors.Snuff_212_213_234_Haiti_18_22_55
    static let Selected = Palette.DualColors.BlueRibbon_White
    static let Unselected = Palette.DualColors.BlackPearl_a50_White_a30
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
    struct Cell {
      static let background = Palette.DualColors.TitanWhite_244_245_255_Haiti_16_18_54
      static let border = Palette.DualColors.Periwinkle_PortGore
    }
  }
  
  struct UserProfile {
    struct Calendar {
      static let background = Palette.DualColors.Selago_220_222_251_PortGore_26_29_67
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
  
  struct Bird {
    struct TypeSmallCollectionViewCell {
      static let selectedText = UIColor.black
      static let selectedTint = UIColor.black
      static let selectedBackground = Palette.SingleColors.Shamrock
      static let unselectedBackground = Palette.DualColors.White_BlackPearl
    }
  }
  
  // Diamond
  struct Diamond {
    struct OfferCell {
      struct selected {
        static let background = Palette.DualColors.Sundown_254_174_181
        static let offerBackground = Palette.DualColors.LavenderRose_254_158_242
      }
      struct notSeleted {
        static let background = Palette.DualColors.TitanWhite_228_229_254_Haiti_17_20_52
        static let offerBackground = Palette.DualColors.TitanWhite_196_198_216_Haiti_7_9_30
      }
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

