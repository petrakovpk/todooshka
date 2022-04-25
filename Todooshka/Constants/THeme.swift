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
    static let background: UIColor? = .Theme.Selago_Haiti_8_10_32
    static let text: UIColor? = .Theme.BlackPearl_White
    static let textInverted: UIColor? = .Theme.White_BlackPearl
    static let placeholder: UIColor? = .Theme.Martinique_a30_Martinique
  }
  
  // TabBar
  struct TabBar {
    static let background: UIColor? = .Theme.Snuff_Haiti_18_22_55
    static let selected: UIColor? = .Theme.BlueRibbon_White
    static let unselected: UIColor? = .Theme.BlackPearl_a50_White_a30
  }
  
  // MainTaskList
  struct MainTaskList {
    static let buttonBackground: UIColor? = .Theme.TitanWhite_228_229_254_Haiti_17_20_52
  }
  
  // TaskListCell
  struct TaskListCell {
    static let descriptionText: UIColor? = .Theme.BlackPearl_a60_White_a60
    static let timeLeftViewBackground: UIColor? = .Theme.BlueBayoux_Haiti_10_13_36
  }
  
  // TypeLargeCollectionViewCell
  struct TypeLargeCollectionViewCell {
    static let selectedText: UIColor? = .white
    static let selectedTint: UIColor? = .white
    static let selectedBackground: UIColor? = .Palette.BlueRibbon
    static let unselectedBackground: UIColor? = .Theme.White_BlackPearl
  }
  
  
  // TypeSmallCollectionViewCell
  struct TypeSmallCollectionViewCell {
    static let selectedText: UIColor? = .black
    static let selectedTint: UIColor? = .black
    static let selectedBackground: UIColor? = .Palette.Shamrock
    static let unselectedBackground: UIColor? = .Theme.White_BlackPearl
  }
  
  // Cell
  struct Cell {
    static let background: UIColor? = .Theme.TitanWhite_244_245_255_Haiti_16_18_54
    static let border: UIColor? = .Theme.Periwinkle_PortGore
  }
  
  // Header
  struct Header {
    static let background: UIColor? = .Theme.TitanWhite_228_229_254_Haiti_17_20_52
    static let dividerBackground: UIColor? = .Theme.HawkesBlue_Haiti_7_9_30
  }
  
  // Onboarding
  struct Onboarding {
    static let dotBackground: UIColor? = .Theme.PeriwinkleGray_Fiord
    static let text: UIColor? = .Palette.SantasGray
  }
   
  // RoundButton
  struct RoundButton {
    static let background: UIColor? = .Theme.BlackPearl_White?.withAlphaComponent(0.1)
    static let tint: UIColor? = .Theme.BlackPearl_White
  }
  
  // Calendar
  struct Calendar {
    
    struct Cell {
      static let border: UIColor? = .Palette.BlueRibbon
      static let selectedBackground: UIColor? = .Palette.BlueRibbon
    }
    
    static let background: UIColor? = .Theme.Selago_PortGore
    static let divider: UIColor? = .Theme.MoonRaker_PortGore
  }
}
