//
//  UIViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.08.2021.
//
import UIKit



extension CompletedTasksListViewController: ConfigureColorProtocol {
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
    //CollectionView
    collectionView.backgroundColor = .clear
  }

}

extension DeletedTasksListViewController: ConfigureColorProtocol {
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
    //CollectionView
    collectionView.backgroundColor = .clear
  }
  

}



extension OverdueTasksListViewController: ConfigureColorProtocol {
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
    //CollectionView
    collectionView.backgroundColor = .clear
  }
  

}








extension UserProfileSettingsViewController: ConfigureColorProtocol {
  
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    tableView.backgroundColor = .clear
  }
  
  func setTextColor() {
    
    
  }
}

