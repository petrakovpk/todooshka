//
//  UIViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.08.2021.
//
import UIKit

extension OnboardingViewController: ConfigureColorProtocol {
  func setViewColor() {
    
    view.backgroundColor = UIColor(named: "appBackground")
    headerLabel.textColor = UIColor(named: "appText")
    
    authButton.backgroundColor = .blueRibbon
    authButton.setTitleColor(.white, for: .normal)
    
    skipButton.backgroundColor = .clear
    skipButton.setTitleColor(.santasGray, for: .normal)
  }
}

extension OnboardingCollectionViewCell: ConfigureColorProtocol {
  func setViewColor() {
    
    contentView.backgroundColor = UIColor(named: "appBackground")
    headerLabel.textColor = UIColor(named: "appText")
    
    descriptionTextView.backgroundColor = .clear
    descriptionTextView.textColor = .santasGray
  }
}

extension AuthViewController: ConfigureColorProtocol {
  func setViewColor() {
    
    view.backgroundColor = UIColor(named: "appBackground")
    headerLabel.textColor = UIColor(named: "appText")
    secondHeaderLabel.textColor = UIColor(named: "appText")
    
    headerDescriptionTextView.backgroundColor = .clear
    headerDescriptionTextView.textColor = .santasGray
  }
}

extension LoginViewController: ConfigureColorProtocol {
  func setViewColor() {
    
    view.backgroundColor = UIColor(named: "appBackground")
    headerLabel.textColor = UIColor(named: "appText")
    secondHeaderLabel.textColor = UIColor(named: "appText")
    
    headerDescriptionTextView.backgroundColor = .clear
    headerDescriptionTextView.textColor = .santasGray
    
    backButton.imageView?.tintColor = UIColor(named: "appText")
    
    emailTextField.backgroundColor = UIColor(named: "authTextFieldBackground")
    emailTextField.borderColor = UIColor(named: "authTextFieldBorder")
    
    passwordTextField.backgroundColor = UIColor(named: "authTextFieldBackground")
    passwordTextField.borderColor = UIColor(named: "authTextFieldBorder")
    
    phoneTextField.backgroundColor = UIColor(named: "authTextFieldBackground")
    phoneTextField.borderColor = UIColor(named: "authTextFieldBorder")
    
    codeTextField.backgroundColor = UIColor(named: "authTextFieldBackground")
    codeTextField.borderColor = UIColor(named: "authTextFieldBorder")
    
    emailButton.setTitleColor(UIColor(named: "appText"), for: .normal)
    phoneButton.setTitleColor(UIColor(named: "authModeButtonTextDisable"), for: .normal)
    
    leftDividerView.backgroundColor = UIColor.blueRibbon
    rightDividerView.backgroundColor = UIColor(named: "authDivider")
    
    nextButton.backgroundColor = UIColor(named: "authDisablesNextButtonBackground")
    nextButton.setTitleColor(UIColor(named: "authDisablesNextButtonText")!.withAlphaComponent(0.12) , for: .normal)
  }
}

extension TaskListViewController: ConfigureColorProtocol {
  
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    collectionView.backgroundColor = .clear
    
    sortedByButton.backgroundColor = UIColor(named: "taskListSortedByButtonBackground")
    sortedByButton.setTitleColor(.white, for: .normal)
  }
}

extension TaskListCollectionViewCell: ConfigureColorProtocol {
  func setViewColor() {
    
  }
}

extension CompletedTasksListViewController: ConfigureColorProtocol {
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
    //CollectionView
    collectionView.backgroundColor = .clear
  }
  
  func setTextColor() {
    
    
  }
}

extension DeletedTasksListViewController: ConfigureColorProtocol {
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
    //CollectionView
    collectionView.backgroundColor = .clear
  }
  
  func setTextColor() {
    
    
  }
}

extension IdeaBoxTaskListViewController: ConfigureColorProtocol {
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
    //CollectionView
    collectionView.backgroundColor = .clear
  }
  
  func setTextColor() {
    
    
  }
}

extension OverdueTasksListViewController: ConfigureColorProtocol {
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
    //CollectionView
    collectionView.backgroundColor = .clear
  }
  
  func setTextColor() {
    
    
  }
}



extension UserProfileViewController: ConfigureColorProtocol {
  
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
  }
  
  func setTextColor() {
    
    
  }
}

extension TaskTypesListViewController: ConfigureColorProtocol {
  
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
  }
  
  func setTextColor() {
    
    
  }
}

extension TaskViewController: ConfigureColorProtocol {
  
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    backButton.imageView?.tintColor = UIColor(named: "text")      
    
  }
  
  func setTextColor() {
    
    
  }
}

extension UserProfileSettingsViewController: ConfigureColorProtocol {
  
  func setViewColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    tableView.backgroundColor = .clear
  }
  
  func setTextColor() {
    
    
  }
}

